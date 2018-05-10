class Game < ApplicationRecord
  has_many :pieces
  has_many :game_setups
  has_many :setups, through: :game_setups

  after_commit :add_pieces, on: :create

  include NotationLogic

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    piece = pieces.find_by(position_index: position_index)
    update_piece(piece, new_position)
    update_board
  end

  def update_notation(position_index, new_position, upgraded_type)
    new_notation = create_notation(position_index, new_position, upgraded_type)

    update(notation: (notation.to_s + new_notation.to_s))
  end

  def update_piece(piece, new_position)
    piece.update(
      position: new_position,
      has_moved: true,
      moved_two: piece.pawn_moved_two?(new_position)
    )
  end

  def update_board
    position_signature = pieces.order(:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.')

    setup = Setup.find_or_create_by(position_signature: position_signature)
    setups << setup
  end

  def current_turn
    notation.to_s.split('.').count.even? ? 'white' : 'black'
  end

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

    json_pieces.each do |json_piece|
      pieces.create(json_piece)
    end
  end
end
