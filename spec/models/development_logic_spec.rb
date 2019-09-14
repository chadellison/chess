require 'rails_helper'

RSpec.describe DevelopmentLogic, type: :model do
  let(:game_data) { GameData.new(Move.new, [Piece.new], 'white', 0) }

  describe 'development_pattern' do
    let(:white_piece1) { Piece.new(color: 'white') }
    let(:white_piece2) { Piece.new(color: 'white') }
    let(:black_piece) { Piece.new(color: 'black') }

    let (:pieces) { [white_piece1, white_piece2, black_piece] }

    describe 'when it is black\'s turn' do
      it 'returns number of ally pieces who have moved over the total pieces moved' do
        allow_any_instance_of(GameData).to receive(:pieces)
          .and_return(pieces)
        allow_any_instance_of(GameData).to receive(:turn)
          .and_return('black')

        allow(white_piece1).to receive(:has_moved).and_return(true)
        allow(white_piece2).to receive(:has_moved).and_return(true)
        allow(black_piece).to receive(:has_moved).and_return(true)

        expect(DevelopmentLogic.development_pattern(game_data)).to eq 0.3
      end
    end

    describe 'when it is white\'s turn' do
      it 'returns number of ally pieces who have moved over the total pieces moved - one' do
        allow_any_instance_of(GameData).to receive(:pieces)
          .and_return(pieces)
        allow_any_instance_of(GameData).to receive(:turn)
          .and_return('white')

        allow(white_piece1).to receive(:has_moved).and_return(true)
        allow(white_piece2).to receive(:has_moved).and_return(true)
        allow(black_piece).to receive(:has_moved).and_return(true)

        expect(DevelopmentLogic.development_pattern(game_data)).to eq 0.5
      end
    end
  end
end
