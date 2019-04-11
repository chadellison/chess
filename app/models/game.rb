class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  belongs_to :ai_player, optional: true, dependent: :destroy

  include PieceHelper
  include CacheLogic

  scope :user_games, ->(user_id) { where(white_player: user_id).or(where(black_player: user_id))}

  scope :find_open_games, (lambda do |user_id|
    where.not(white_player: user_id)
         .or(where.not(black_player: user_id))
         .where(status: 'awaiting player')
  end)

  class << self
    def create_user_game(user, game_params)
      game = Game.new(game_type: game_params[:game_type])
      game_params[:color] == 'white' ? game.white_player = user.id : game.black_player = user.id

      if game_params[:game_type] == 'human vs machine'
        machine_player = create_ai_player(game_params[:color])
        game.ai_player = machine_player
        game.status = 'active'
      else
        game.status = 'awaiting player'
      end
      game.save
      game.ai_logic.ai_move(game.current_turn) if game.ai_turn?
      game
    end

    def create_ai_player(color)
      if color == 'white'
        ai_color = 'black'
      else
        ai_color = 'white'
      end
      AiPlayer.create(color: ai_color, name: Faker::Name.name)
    end

    def pieces_with_next_move(game_pieces, move)
      castle = false
      en_passant = false
      piece_index = move.to_i
      updated_pieces = game_pieces.reject { |piece| piece.position == move[-2..-1] }
        .map do |piece|
          game_piece = Piece.new(
            color: piece.color,
            piece_type: piece.piece_type,
            position_index: piece.position_index,
            game_id: piece.game_id,
            position: piece.position,
            has_moved: piece.has_moved
          )

          if piece.position_index == piece_index
            game_piece.moved_two = game_piece.piece_type == 'pawn' && game_piece.forward_two?(move[-2..-1])
            castle = game_piece.king_moved_two?(move[-2..-1])
            en_passant = en_passant?(piece, move[-2..-1], game_pieces)
            game_piece.piece_type = 'queen' if should_promote_pawn?(move)
            game_piece.position = move[-2..-1]
            game_piece.has_moved = true
          end

          game_piece
        end

      updated_pieces = update_rook(move, updated_pieces) if castle
      updated_pieces = handle_en_passant(move, updated_pieces) if en_passant
      updated_pieces
    end

    def en_passant?(piece, position, game_pieces)
      [
        piece.piece_type == 'pawn',
        piece.position[0] != position[0],
        game_pieces.detect { |p| p.position == position }.blank?
      ].all?
    end

    def should_promote_pawn?(move_value)
      (9..24).include?(move_value.to_i) &&
        (move_value[-1] == '8' || move_value[-1] == '1')
    end

    def update_rook(king_move, game_pieces)
      new_rook_column = king_move[-2] == 'g' ? 'f' : 'd'
      new_rook_row = king_move[-1] == '1' ? '1' : '8'

      new_rook_position = new_rook_column + new_rook_row

      rook_index = case new_rook_position
      when 'd8' then 1
      when 'f8' then 8
      when 'd1' then 25
      when 'f1' then 32
      end

      game_pieces.map do |game_piece|
        if game_piece.position_index == rook_index
          game_piece.position = new_rook_position
        end
        game_piece
      end
    end

    def handle_en_passant(pawn_move_value, updated_pieces)
      captured_row = pawn_move_value[-1] == '6' ? '5' : '3'
      updated_pieces.reject do |game_piece|
        game_piece.position == pawn_move_value[-2] + captured_row
      end
    end
  end

  def ai_logic
    @ai_logic ||= AiLogic.new(self)
  end

  def notation_logic
    @notation_logic ||= Notation.new(self)
  end

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    update_game(position_index, new_position, upgraded_type)
    handle_human_game if game_type.include?('human')
    return handle_outcome if game_over?(pieces, current_turn)
    ai_logic.ai_move(current_turn) if ai_turn?
  end

  def handle_human_game
    GameEventBroadcastJob.perform_later(self)
    reload_pieces
  end

  def handle_move(move_value, upgraded_type = '')
    position_index = move_value.to_i
    new_position = move_value[-2..-1]
    update_notation(move_value.to_i, new_position, upgraded_type)
    update_game(position_index, new_position, upgraded_type)
    handle_human_game if game_type.include?('human')
    return handle_outcome if game_over?(pieces, current_turn)
  end

  def game_over?(pieces, game_turn)
    checkmate?(pieces, game_turn) || stalemate?(pieces, game_turn)
  end

  def handle_outcome
    if checkmate?(pieces, current_turn)
      outcome = current_turn == 'black' ? 1 : 0
    else
      outcome = 0.5
    end
    update(outcome: outcome.to_s)
    GameEventBroadcastJob.perform_later(self) if game_type.include?('human')
  end

  def join_user_to_game(user_id)
    if white_player.blank?
      update(white_player: user_id, status: 'active')
    else
      update(black_player: user_id, status: 'active')
    end
    GameEventBroadcastJob.perform_later(self)
  end

  def ai_turn?
    ai_player.present? && current_turn == ai_player.color
  end

  def current_turn
    moves.count.even? ? 'white' : 'black'
  end

  def opponent_color
    current_turn == 'white' ? 'black' : 'white'
  end

  def update_notation(position_index, new_position, upgraded_type)
    new_notation = notation_logic.create_notation(position_index, new_position, upgraded_type)

    update(notation: (notation.to_s + new_notation.to_s))
  end

  def update_game(position_index, new_position, upgraded_type = '')
    move_key = notation.split('.')[0..(moves.count)].join('.')
    if in_cache?(move_key)
      moves << get_move(move_key)
      reload_pieces
    else
      piece = find_piece_by_index(position_index)
      updated_piece = Piece.new_piece(piece, new_position, upgraded_type)
      update_board(piece, updated_piece)
    end
  end

  def update_board(piece, updated_piece)
    new_pieces = Game.pieces_with_next_move(pieces, updated_piece.position_index.to_s + updated_piece.position)
    update_pieces(new_pieces)

    game_move = Move.new(
      value: (piece.position_index.to_s + updated_piece.position),
      move_count: (moves.count + 1),
      promoted_pawn: (promoted_pawn?(updated_piece) ? updated_piece.piece_type : nil)
    )

    setup = Setup.save_setup_and_signatures(new_pieces, opponent_color[0])
    game_move.setup = setup
    add_to_cache(notation.split('.')[0..(moves.count)].join('.'), game_move)
    moves << game_move
    game_move.save
  end

  def promoted_pawn?(piece)
    (9..24).include?(piece.position_index) && piece.piece_type != 'pawn'
  end

  def checkmate?(game_pieces, turn)
    no_valid_moves?(game_pieces, turn) &&
      !pieces.detect { |piece| piece.color == turn }.king_is_safe?(turn, game_pieces)
  end

  def stalemate?(game_pieces, turn)
    king = pieces.detect { |piece| piece.color == current_turn }
    [
      no_valid_moves?(game_pieces, turn) && king.king_is_safe?(current_turn, game_pieces),
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
      piece.valid_moves(game_pieces).blank?
    end
  end

  def machine_vs_machine
    until outcome.present? do
      ai_logic.ai_move(current_turn)
      update(outcome: 0) if moves.count > 400
      puts moves.order(:move_count).last.value
      puts '******************'
    end
  end

  def update_outcomes
    moves.each { |move| move.setup.update_outcomes(outcome) }
  end
end
