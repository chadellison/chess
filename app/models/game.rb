class Game < ApplicationRecord
  has_many :pieces, dependent: :destroy
  has_many :moves, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  after_commit :add_pieces, on: :create

  include NotationLogic
  include BoardLogic
  include AiLogic

  scope :winning_games, ->(win) { where(outcome: win) }
  scope :active_games, -> { where(status: ['active', 'awaiting player']) }
  scope :user_games, ->(user_id) { where(white_player: user_id).or(where(black_player: user_id))}

  scope :similar_games, (lambda do |move_notation|
    where('notation LIKE ?', "#{move_notation}%")
  end)

  def self.create_user_game(user, game_params)
    game = Game.new(game_type: game_params[:game_type])
    game_params[:color] == 'white' ? game.white_player = user.id : game.black_player = user.id
    game.status = 'active' if game_params[:game_type].include?('machine')
    game.save
    game
  end

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    piece = pieces.find_by(position_index: position_index)
    update_game(piece, new_position, upgraded_type)
    GameEventBroadcastJob.perform_later(self)
  end

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

    json_pieces.each do |json_piece|
      pieces.create(json_piece)
    end
  end
end
