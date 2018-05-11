class Game < ApplicationRecord
  has_many :pieces, dependent: :delete_all
  has_many :moves, dependent: :delete_all

  after_commit :add_pieces, on: :create

  include NotationLogic
  include BoardLogic
  include AiLogic

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
