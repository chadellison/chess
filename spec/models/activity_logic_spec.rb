require 'rails_helper'

RSpec.describe ActivityLogic, type: :model do
  let(:game_data) { GameData.new(Move.new, [Piece.new], 'white', 3) }
  
  describe 'activity_pattern' do
    let(:white_piece) { Piece.new(color: 'white') }

    let(:black_piece) { Piece.new(color: 'black') }
    let (:pieces) { [white_piece, black_piece] }

    it 'returns the move count over the total available moves' do
      allow_any_instance_of(GameData).to receive(:pieces)
        .and_return(pieces)

      allow(white_piece).to receive(:valid_moves).and_return(['a1', 'a2'])
      allow(black_piece).to receive(:valid_moves).and_return(['a1'])

      game_data = GameData.new(Move.new, pieces, 'white', 0)
      expect(ActivityLogic.activity_pattern(game_data)).to eq 0.7
    end
  end
end
