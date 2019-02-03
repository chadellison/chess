require 'rails_helper'

RSpec.describe StockfishIntegration do
  describe 'find_stockfish_move' do
    it 'returns a move' do
      game = Game.new
      stockfish_integration = StockfishIntegration.new(game)

      expect(stockfish_integration.find_stockfish_move.length).to eq 4
      expect(("a".."h").include?(stockfish_integration.find_stockfish_move[0])).to be true
      expect(("1".."8").include?(stockfish_integration.find_stockfish_move[1])).to be true
      expect(("a".."h").include?(stockfish_integration.find_stockfish_move[2])).to be true
      expect(("1".."8").include?(stockfish_integration.find_stockfish_move[3])).to be true
    end
  end

  describe 'stockfish_color' do
    let(:game) { Game.new }
    let(:stockfish_integration) { StockfishIntegration.new(game) }

    context 'when the game_number is even' do
      it 'returns white' do
        expect(stockfish_integration.stockfish_color(2)).to eq 'white'
      end
    end

    context 'when the game_number is odd' do
      it 'returns black' do
        expect(stockfish_integration.stockfish_color(1)).to eq 'black'
      end
    end
  end

  describe 'find_upgraded_type' do
    let(:game) { Game.new }
    let(:stockfish_integration) { StockfishIntegration.new(game) }

    context 'for q' do
      it 'returns queen' do
        expect(stockfish_integration.find_upgraded_type('q')).to eq 'queen'
      end
    end

    context 'for r' do
      it 'returns rook' do
        expect(stockfish_integration.find_upgraded_type('r')).to eq 'rook'
      end
    end

    context 'for b' do
      it 'returns bishop' do
        expect(stockfish_integration.find_upgraded_type('b')).to eq 'bishop'
      end
    end

    context 'for n' do
      it 'returns knight' do
        expect(stockfish_integration.find_upgraded_type('n')).to eq 'knight'
      end
    end

    context 'when the letter is not present' do
      it 'returns an empty string' do
        expect(stockfish_integration.find_upgraded_type('')).to eq ''
      end
    end
  end
end
