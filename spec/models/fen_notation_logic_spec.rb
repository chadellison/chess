require 'rails_helper'

RSpec.describe FenNotationLogic, type: :module do
  describe 'find_fen_notation' do
    context 'when there are no game moves' do
      let(:game) { Game.new }

      it 'returns the new board setup' do
        expected = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        expect(game.find_fen_notation).to eq expected
      end
    end

    context 'when there are game moves' do
      let(:game) { Game.new }

      it 'calls fen_piece_positions and fen_game_data' do
        game.moves << Move.new
        expect(game).to receive(:fen_piece_positions)
          .and_return('fen_position')

        expect(game).to receive(:fen_game_data)
          .and_return('fen_game_data')

        game.find_fen_notation
      end
    end
  end

  describe 'fen_piece_positions' do
    xit 'test' do

    end
  end

  describe 'fen_game_data' do
    xit 'test' do

    end
  end

  describe 'fen_castle_codes' do
    xit 'test' do

    end
  end

  describe 'fen_piece_type' do
    xit 'test' do

    end
  end
end
