require 'rails_helper'

RSpec.describe BoardLogic, type: :module do
  describe 'update_notation' do
    it 'calls create_notation' do
      allow_any_instance_of(Game).to receive(:add_pieces)

      expect_any_instance_of(Game).to receive(:create_notation)
        .with(9, 'a3', '')

      game = Game.create
      game.update_notation(9, 'a3', '')
    end

    it 'updates the game\'s notation' do
      allow_any_instance_of(Game).to receive(:create_notation)
        .and_return('123')

      game = Game.create(notation: 'abc')
      game.update_notation(9, 'a3', '')

      expect(game.notation).to eq 'abc123'
    end
  end

  describe 'update_game' do
    xit 'test' do
    end
  end

  describe 'update_piece' do
    it 'deletes a piece when it is on an occupied square' do
      game = Game.create

      piece = game.pieces.find_by(position: 'd2')
      piece.update(position: 'd6')

      expect { game.update_piece(piece, 'e7', '') }
        .to change { game.pieces.count }.by(-1)

      expect(game.pieces.reload.find_by(position: 'e7').id).to be piece.id
    end
  end

  describe 'update_board' do
    it 'creates a move position_signature of the current board positions' do
      game = Game.create
      piece = game.pieces.first
      game.update_board(piece)

      expected = '1a8.2b8.3c8.4d8.5e8.6f8.7g8.8h8.9a7.10b7.11c7.12d7.13e7.14f7.15g7.16h7.17a2.18b2.19c2.20d2.21e2.22f2.23g2.24h2.25a1.26b1.27c1.28d1.29e1.30f1.31g1.32h1'

      actual = game.moves.first.setup.position_signature
      expect(actual).to eq expected
    end

    it 'creates a setup if it does not already exist' do
      game = Game.create
      piece = game.pieces.first

      expect { game.update_board(piece) }.to change { Setup.count }.by(1)
    end

    it 'creates a move' do
      game = Game.create
      piece = game.pieces.first

      expect { game.update_board(piece) }.to change { game.moves.count }.by(1)
    end
  end

  describe 'create_move' do
    xit 'test' do
    end
  end

  describe 'create_signature' do
    it 'creates a position signature from the pieces' do
      game = Game.new

      pieces = [
        Piece.new(position_index: 1, position: 'd2'),
        Piece.new(position_index: 10, position: 'b3')
      ]

      expect(game.create_signature(pieces)).to eq '1d2.10b3'
    end
  end

  describe 'handle_castle' do
    context 'when the king has castled queen side' do
      let(:game) { Game.create }

      it 'updates the rook\'s position to the f column' do
        piece = game.pieces.find_by(position_index: 29)

        game.handle_castle(piece, 'c1')

        expect(game.pieces.find_by(position_index: 25).position).to eq 'd1'
      end
    end

    context 'when the king has castled king side' do
      let(:game) { Game.create }

      it 'updates the rook\'s position to the f column' do
        piece = game.pieces.find_by(position_index: 29)

        game.handle_castle(piece, 'g1')

        expect(game.pieces.find_by(position_index: 32).position).to eq 'f1'
      end
    end

    context 'when the king has not moved two spaces' do
      let(:game) { Game.create }
      it 'does nothing' do
        piece = game.pieces.find_by(position_index: 29)

        game.handle_castle(piece, 'f1')

        expect(game.pieces.find_by(position_index: 25).position).to eq 'a1'
        expect(game.pieces.find_by(position_index: 32).position).to eq 'h1'
      end
    end
  end

  describe 'handle_en_passant' do
    it 'removes the captured piece' do
      game = Game.create

      piece = game.pieces.find_by(position: 'd2')
      piece.update(position: 'd5')
      game.pieces.find_by(position: 'e7').update(position: 'e5')

      expect { game.handle_en_passant(piece, 'e6') }
        .to change { game.pieces.count }.by(-1)

      expect(game.pieces.find_by(position: 'e5').blank?).to be true
    end
  end

  describe 'en_passant?' do
    context 'when a pawn can en Passant' do
      let!(:game) { Game.create }

      before do
        game.pieces.find_by(position_index: 20).update(position: 'd4')
        game.pieces.find_by(position_index: 13).update(position: 'e4', moved_two: true)
      end

      it 'returns true' do
        piece = game.pieces.find_by(position_index: 20)

        expect(game.en_passant?(piece, 'e5')).to be true
      end
    end

    context 'when a pawn did not en passant' do
      let!(:game) { Game.create }

      it 'returns false' do
        piece = game.pieces.find_by(position_index: 20)

        expect(game.en_passant?(piece, 'd4')).to be false
      end
    end
  end

  describe '#checkmate?' do
    let!(:checkmate_game) { Game.create }

    context 'when the king is in checkmate' do
      before do
        checkmate_game.pieces.find_by(position: 'e2').update(position: 'd4')
        checkmate_game.pieces.find_by(position: 'e7').update(position: 'd5')
        checkmate_game.pieces.find_by(position: 'd1').update(position: 'f7')
        checkmate_game.pieces.find_by(position: 'b8').update(position: 'c6')
        checkmate_game.pieces.find_by(position: 'f1').update(position: 'c4')
        checkmate_game.pieces.find_by(position: 'g8').update(position: 'f6')
      end

      it 'returns true' do
        checkmate_game.reload
        expect(checkmate_game.checkmate?(checkmate_game.pieces, 'black')).to be true
      end
    end

    context 'when the king is not in checkmate' do
      it 'returns false' do
        expect(checkmate_game.checkmate?(checkmate_game.pieces, 'black')).to be false
      end
    end
  end

  describe 'no_valid_moves?' do
    xit 'test' do
    end
  end
end
