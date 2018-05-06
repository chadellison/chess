require 'rails_helper'

RSpec.describe Piece, type: :model do
  it 'belongs to a game' do
    piece = Piece.new(
      position: 'a2',
      piece_type: 'knight',
      color: 'white',
      position_index: Faker::Number.number(2)
    )
    game = Game.new
    game.pieces << piece

    expect(piece.game).to eq game
  end
end
