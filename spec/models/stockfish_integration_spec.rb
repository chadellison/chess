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

  describe 'find_piece_index' do
    let(:game) { Game.new }
    let(:stockfish_integration) { StockfishIntegration.new(game) }

    it 'calls find_piece_by_position on a game' do
      piece = Piece.new(position_index: 1)
      expect(game).to receive(:find_piece_by_position)
        .with('a1')
        .and_return(piece)

        expect(stockfish_integration.find_piece_index('a1b2')).to eq 1
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

  describe 'find_fen_notation' do
    context 'when there are no game moves' do
      let(:game) { Game.new }
      let(:stockfish_integration) { StockfishIntegration.new(game) }

      it 'returns the new board setup' do
        expected = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        expect(stockfish_integration.find_fen_notation).to eq expected
      end
    end

    context 'when there are game moves' do
      let(:game) { Game.new }
      let(:stockfish_integration) { StockfishIntegration.new(game) }

      it 'calls fen_piece_positions and fen_game_data' do
        game.moves << Move.new
        expect(stockfish_integration).to receive(:fen_piece_positions)
          .and_return('fen_position')

        expect(stockfish_integration).to receive(:fen_game_data)
          .and_return('fen_game_data')

        stockfish_integration.find_fen_notation
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
