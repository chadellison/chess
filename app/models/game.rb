class Game < ApplicationRecord
  has_many :pieces, dependent: :delete_all
  # has_many :game_setups
  # has_many :setups, through: :game_setups
  has_many :moves

  after_commit :add_pieces, on: :create

  include NotationLogic
  include BoardLogic
  include AiLogic

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    piece = pieces.find_by(position_index: position_index)
    update_piece(piece, new_position, upgraded_type)
    update_board(piece)
  end

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

    json_pieces.each do |json_piece|
      pieces.create(json_piece)
    end
  end
end
