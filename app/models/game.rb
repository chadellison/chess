class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  belongs_to :ai_player, optional: true, dependent: :destroy

  after_commit :add_pieces, on: :create

  include NotationLogic
  include BoardLogic
  include AiLogic

  scope :winning_games, ->(win) { where(outcome: win) }
  scope :user_games, ->(user_id) { where(white_player: user_id).or(where(black_player: user_id))}
  scope :similar_games, ->(move_notation) { where('notation LIKE ?', "#{move_notation}%") }

  scope :find_open_games, (lambda do |user_id|
    where.not(white_player: user_id)
      .or(where.not(black_player: user_id))
      .where(status: 'awaiting player')
  end)

  def self.create_user_game(user, game_params)
    game = Game.new(game_type: game_params[:game_type])
    game_params[:color] == 'white' ? game.white_player = user.id : game.black_player = user.id

    if game_params[:game_type].include?('machine')
      machine_player = create_ai_player(game_params[:color])
      game.ai_player = machine_player
      game.status = 'active'
    else
      game.status = 'awaiting player'
    end
    game.save
    game.ai_move if game.ai_turn?
    game
  end

  def self.create_ai_player(color)
    if color == 'white'
      ai_color = 'black'
    else
      ai_color = 'white'
    end
    AiPlayer.create(color: ai_color, name: Faker::Name.name)
  end

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    piece = find_piece_by_index(position_index)
    update_game(piece, new_position, upgraded_type)

    GameEventBroadcastJob.perform_later(self)
    return handle_outcome if checkmate?(pieces, current_turn) || stalemate?(pieces, current_turn)
    ai_move if ai_turn?
  end

  def handle_outcome
    if checkmate?(pieces, current_turn)
      outcome = current_turn == 'black' ? 1 : -1
    else
      outcome = 0
    end
    update(outcome: outcome)
    GameEventBroadcastJob.perform_later(self)
  end

  def add_pieces
    return @pieces if @pieces.present?
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))
                      .map(&:symbolize_keys)

    @pieces = json_pieces.map do |json_piece|
      json_piece[:game_id] = id
      Piece.new(json_piece)
    end
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

  def pieces
    if moves.count > 0
      return @pieces if @pieces.present?
      signature = moves.order(:move_count).last.setup.position_signature
      move_indices = moves.map { |move| position_index_from_move(move.value).to_i }

      pawn_moved_two = pawn_moved_two?
      last_move = moves.order(:move_count).last
      @pieces = signature.split('.').map do |piece_value|
        position_index = position_index_from_move(piece_value).to_i
        moved_two = (pawn_moved_two && position_index == last_move_index(last_move)) ? true : false
        Piece.new({
          game_id: id,
          position: piece_value[-2..-1],
          position_index: position_index,
          color: color_from_position_index(position_index),
          piece_type: piece_type_from_position_index(position_index),
          has_moved: move_indices.include?(position_index),
          moved_two: moved_two
        })
      end
    else
      add_pieces
    end
  end

  def color_from_position_index(position_index)
    position_index < 17 ? 'black' : 'white'
  end

  def piece_type_from_position_index(position_index)
    # this should handle promoted pawns lool at moves for promoted value
    return 'king' if [5, 29].include?(position_index)
    return 'queen' if [4, 28].include?(position_index)
    return 'bishop' if [3, 6, 27, 30].include?(position_index)
    return 'knight' if [2, 7, 26, 31].include?(position_index)
    return 'rook' if [1, 8, 25, 32].include?(position_index)
    return 'pawn'
  end

  def find_piece_by_position(position)
    pieces.detect { |piece| piece.position == position }
  end

  def find_piece_by_index(index)
    pieces.detect { |piece| piece.position_index == index }
  end

  def last_move_index(last_move)
    position_index_from_move(last_move.value).to_i
  end

  def pawn_moved_two?
    last_move = moves.order(:move_count).last
    last_moved_piece_type = piece_type_from_position_index(last_move_index(last_move))
    return false unless last_moved_piece_type == 'pawn'

    if moves.count == 1
      ['4', '5'].include?(last_move.value[-1])
      true
    else
      previous_position = moves[-2].setup.position_signature.split('.').detect do |value|
        position_index_from_move(value).to_i == last_move_index(last_move)
      end[-2..-1]

      if previous_position[1].to_i.abs - last_move.value[-1].to_i.abs == 2
        pawn_moved_two = true
      end
    end
  end
end
