require 'rails_helper'

RSpec.describe PieceHelper, type: :module do
  describe 'add_pieces' do
    context 'when the pieces attribute is nil' do
      it 'returns 32 pieces' do
        game = Game.new

        expect(game.add_pieces.count).to eq 32
      end
    end
  end

  describe 'pieces' do
    context 'when a game\'s move count is 0' do
      it 'calls add_pieces' do
        game = Game.new

        expect_any_instance_of(Game).to receive(:add_pieces)

        game.pieces
      end
    end

    context 'when a game\'s move count is not 0' do
      xit 'test' do

      end
    end
  end
end
