class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  belongs_to :ai_player, optional: true, dependent: :destroy

  include PieceHelper
  include CacheLogic

  scope :user_games, (lambda do |user_id|
    where(white_player: user_id)
      .or(where(black_player: user_id))
  end)

  scope :find_open_games, (lambda do |user_id|
    where.not(white_player: user_id)
         .or(where.not(black_player: user_id))
         .where(status: 'awaiting player')
  end)

  def ai_logic
    @ai_logic ||= AiLogic.new
  end

  def notation_logic
    @notation_logic ||= Notation.new
  end

  def game_move_logic
    @game_move_logic ||= GameMoveLogic.new
  end

  def pgn_logic
    @pgn_logic || PgnLogic.new
  end

  def move(position_index, new_position, upgraded_type = '')
    self.notation = update_notation(position_index, new_position, upgraded_type)
    update_game(position_index, new_position, upgraded_type)
    self.piece_signature = update_piece_signature
    self.save
    handle_move_events
  end

  def handle_move_events
    GameEventBroadcastJob.perform_later(self) if for_human?
    AllGamesEventBroadcastJob.perform_later(self) if for_human?
    turn = current_turn

    if game_over?(pieces, turn)
      handle_outcome
    elsif ai_turn?(turn)
      AiMoveJob.perform_later(self)
    end
  end

  def self.handle_game_observations
    (1..4).map do
      move = Move.offset(rand(0...Move.count)).first
      game_moves = move.game.moves.order(:move_count)[0...move.move_count]
      game_notation = move.game.notation.split('.')[0...move.move_count].join('.') + '.'
      random_game = Game.create(
        notation: game_notation,
        game_type: 'machine vs machine',
        status: 'active'
      )
      random_game.moves = game_moves.map do |m|
        m.game = random_game
        m
      end
      MachineVsMachineJob.perform_later(random_game)
      random_game
    end
  end

  def game_over?(pieces, game_turn)
    checkmate?(pieces, game_turn) || stalemate?(pieces, game_turn)
  end

  def handle_outcome
    turn = current_turn
    if checkmate?(pieces, turn)
      outcome = turn == 'black' ? WHITE_WINS : BLACK_WINS
    else
      outcome = DRAW
    end
    update(outcome: outcome.to_s)
    GameEventBroadcastJob.perform_later(self) if for_human?
    AllGamesEventBroadcastJob.perform_later(self) if for_human?
  end

  def for_human?
    game_type.include?('human') || game_type == 'machine vs machine'
  end

  def join_user_to_game(user_id)
    if white_player.blank?
      update(white_player: user_id, status: 'active')
    else
      update(black_player: user_id, status: 'active')
    end
    GameEventBroadcastJob.perform_later(self)
  end

  def ai_turn?(turn)
    ai_player.present? && turn == ai_player.color
  end

  def current_turn
    move_count.even? ? 'white' : 'black'
  end

  def opponent_color
    current_turn == 'white' ? 'black' : 'white'
  end

  def update_notation(position_index, new_position, upgraded_type)
    new_notation = notation_logic.create_notation(
      position_index,
      new_position,
      upgraded_type,
      pieces
    )
    (notation.to_s.split('.') << new_notation.to_s).join('.')
  end

  def update_game(position_index, new_position, upgraded_type = '')
    piece = find_piece_by_index(position_index)
    updated_piece = Piece.new_piece(piece, new_position, upgraded_type)
    new_pieces = game_move_logic.refresh_board(pieces, updated_piece.position_index.to_s + updated_piece.position)
    update_pieces(new_pieces)
    handle_move(updated_piece)
  end

  def handle_move(updated_piece)
    if move_count < 50 && in_cache?(notation)
      moves << get_move(notation)
    else
      game_move = initialize_move(updated_piece)
      fen_data = pgn_logic.convert_to_fen(notation)
      setup = Setup.find_setup(fen_data)
      setup.save
      game_move.setup = setup
      add_to_cache(notation, game_move) if moves.size < 50
      moves << game_move
    end
  end

  def initialize_move(updated_piece)
    Move.new(
      value: (updated_piece.position_index.to_s + updated_piece.position),
      move_count: move_count,
      promoted_pawn: (promoted_pawn?(updated_piece) ? updated_piece.piece_type : nil)
    )
  end

  def promoted_pawn?(piece)
    (9..24).include?(piece.position_index) && piece.piece_type != 'pawn'
  end

  def checkmate?(game_pieces, turn)
    no_valid_moves?(game_pieces, turn) &&
      !Piece.king_is_safe?(turn, game_pieces)
  end

  def stalemate?(game_pieces, turn)
    [
      no_valid_moves?(game_pieces, turn) && Piece.king_is_safe?(turn, game_pieces),
      insufficient_pieces?,
      three_fold_repitition?
    ].any?
  end

  def insufficient_pieces?
    black_pieces = pieces.select { |piece| piece.color == 'black' }.map(&:piece_type)
    white_pieces = pieces.select { |piece| piece.color == 'white' }.map(&:piece_type)
    piece_types = ['queen', 'pawn', 'rook']

    [black_pieces, white_pieces].all? do |pieces_left|
      pieces_left.count < 3 &&
        pieces_left.none? { |piece| piece_types.include?(piece) }
    end
  end

  def three_fold_repitition?
    moves.count > 9 && moves.last(8).map(&:value).uniq.count < 5
  end

  def no_valid_moves?(game_pieces, turn)
    game_pieces.select { |piece| piece.color == turn }.all? do |piece|
      piece.valid_moves.blank?
    end
  end

  def machine_vs_machine
    until outcome.present?
      ai_move
      update(outcome: 0) if move_count > 400
      puts moves.order(:move_count).last.value
    end
  end

  def ai_move
    turn = current_turn
    possible_moves = game_move_logic.find_next_moves(pieces, turn, notation)
    checkmate_move = possible_moves.detect { |move| move.checkmate.present? }

    if checkmate_move.present?
      move_value = checkmate_move.value
    else
      move_value = ai_logic.analyze(possible_moves, turn)
    end

    move(move_value.to_i, move_value[-2..-1], promote_pawn(move_value))
  end

  def crossed_pawn?(move_value)
    (9..24).include?(move_value.to_i) &&
      (move_value[-1] == '1' || move_value[-1] == '8')
  end

  def promote_pawn(move_value)
    crossed_pawn?(move_value) ? 'queen' : ''
  end

  def move_count
    if notation.present?
      notation.split('.').size
    else
      moves.count
    end
  end

  def update_outcomes
    moves.each { |move| move.setup.update_outcomes(outcome) }
  end

  def update_piece_signature
    pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.')
  end
end
