class Game < ApplicationRecord
  has_many :pieces, dependent: :destroy
  has_many :moves, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

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
    game_params[:game_type].include?('machine') ? game.status = 'active' : game.status = 'awaiting player'
    game.save
    game
  end

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    piece = pieces.find_by(position_index: position_index)
    update_game(piece, new_position, upgraded_type)
    GameEventBroadcastJob.perform_later(self)
    return handle_outcome if checkmate?(pieces, opponent_color) #|| stalemate?
    ai_move if ai_turn?
  end

  def handle_outcome
    if checkmate?(pieces, opponent_color)
      outcome = opponent_color == 'black' ? 1 : -1
    else
      outcome = 0
    end
    update(outcome: outcome)
    GameEventBroadcastJob.perform_later(self)
  end

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

    json_pieces.each do |json_piece|
      pieces.create(json_piece)
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
    current_turn == 'white' && white_player.blank? || current_turn == 'black' && black_player.blank?
  end
end
