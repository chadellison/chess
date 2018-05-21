class Game < ApplicationRecord
  has_many :pieces, dependent: :destroy
  has_many :moves, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  after_commit :add_pieces, on: :create

  include NotationLogic
  include BoardLogic
  include AiLogic

  scope :winning_games, ->(win) { where(outcome: win) }
  scope :active_games, -> { where(active: true) }

  scope :similar_games, (lambda do |move_notation|
    where('notation LIKE ?', "#{move_notation}%")
  end)

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    piece = pieces.find_by(position_index: position_index)
    update_game(piece, new_position, upgraded_type)
  end

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

    json_pieces.each do |json_piece|
      pieces.create(json_piece)
    end
  end
end
