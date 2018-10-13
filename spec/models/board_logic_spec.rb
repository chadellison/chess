require 'rails_helper'

RSpec.describe BoardLogic, type: :module do
  describe 'pieces_with_next_move' do
    it 'returns all of the pieces with the next move given' do
      game = Game.create

      piece = game.find_piece_by_position('d2')
      actual = game.pieces_with_next_move(game.pieces, '20d4')

      expect(actual.map(&:position).include?('d4')).to be true
    end
  end

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

  describe 'update_board' do
    it 'creates a move position_signature of the current board positions' do
      game = Game.create
      piece = game.find_piece_by_index(1)
      game.update_board(piece, 'a6')

      expected = '1a6.2b8.3c8.4d8.5e8.6f8.7g8.8h8.9a7.10b7.11c7.12d7.13e7.14f7.15g7.16h7.17a2.18b2.19c2.20d2.21e2.22f2.23g2.24h2.25a1.26b1.27c1.28d1.29e1.30f1.31g1.32h1'

      actual = game.moves.first.setup.position_signature
      expect(actual).to eq expected
    end

    it 'creates a setup if it does not already exist' do
      game = Game.create
      piece = game.pieces.first

      expect { game.update_board(piece, 'd6') }.to change { Setup.count }.by(1)
    end

    it 'creates a move' do
      game = Game.create
      piece = game.pieces.first

      expect { game.update_board(piece, 'd5') }.to change { game.moves.count }.by(1)
    end
  end

  describe 'new_move' do
    it 'returns a move' do
      game = Game.create
      piece = Piece.new(position: 'a1', position_index: 1, piece_type: 'rook', game_id: game.id)

      actual = game.new_move(piece)
      expect(actual.value).to eq '1a1'
      expect(actual.move_count).to eq 1
    end
  end

  describe 'create_signature' do
    it 'creates a position signature from the pieces' do
      game = Game.new

      pieces = [
        Rook.new(position_index: 1, position: 'd2'),
        Pawn.new(position_index: 10, position: 'b3')
      ]

      expect(game.create_signature(pieces)).to eq '1d2.10b3'
    end
  end

  describe 'update_rook' do
    context 'when the white king has castled queen side' do
      let(:game) { Game.create }

      it 'updates the rook\'s position to the f column' do
        king = game.find_piece_by_index(29)
        rook = game.find_piece_by_index(25)

        game.update_pieces([rook, king])

        game.update_rook('29c1', [rook, king])

        expect(game.find_piece_by_index(25).position).to eq 'd1'
      end
    end

    context 'when the white king has castled king side' do
      let(:game) { Game.create }

      it 'updates the rook\'s position to the f column' do
        piece = game.find_piece_by_index(29)

        game.update_rook('29g1', game.pieces)

        expect(game.find_piece_by_index(32).position).to eq 'f1'
      end
    end

    context 'when the black king has castled queen side' do
      let(:game) { Game.create }

      it 'updates the rook\'s position to the f column' do
        king = game.find_piece_by_index(5)
        rook = game.find_piece_by_index(1)

        game.update_pieces([rook, king])

        game.update_rook('5c8', [rook, king])

        expect(game.find_piece_by_index(1).position).to eq 'd8'
      end
    end

    context 'when the black king has castled king side' do
      let(:game) { Game.create }

      it 'updates the rook\'s position to the f column' do
        piece = game.find_piece_by_index(5)

        game.update_rook('5g8', game.pieces)

        expect(game.find_piece_by_index(8).position).to eq 'f8'
      end
    end
  end

  describe 'handle_en_passant' do
    it 'removes the captured piece' do
      game = Game.create

      piece = game.find_piece_by_position('d2')
      piece.position = 'd5'
      game.find_piece_by_position('e7').position = 'e5'

      actual = game.handle_en_passant('20e6', game.pieces)
      expect(actual.count).to eq 31
      expect(actual.detect { |pawn| pawn.position == 'e5' }.blank?).to be true
    end
  end

  describe 'en_passant?' do
    context 'when a pawn can en Passant' do
      let!(:game) { Game.create }

      before do
        game.find_piece_by_index(20).position = 'd4'
        piece = game.find_piece_by_index(13)
        piece.position = 'e4'
        piece.moved_two = true
      end

      it 'returns true' do
        piece = game.find_piece_by_index(20)

        expect(game.en_passant?(piece, 'e5')).to be true
      end
    end

    context 'when a pawn did not en passant' do
      let!(:game) { Game.create }

      it 'returns false' do
        piece = game.find_piece_by_index(20)

        expect(game.en_passant?(piece, 'd4')).to be false
      end
    end
  end

  describe '#checkmate?' do
    let!(:checkmate_game) { Game.create }

    context 'when the king is in checkmate' do
      it 'returns true' do
        pieces = [
          Queen.new(
            position: 'e7',
            color: 'white',
            position_index: 28,
            game_id: checkmate_game.id
          ),

          King.new(
            position: 'e8',
            color: 'black',
            position_index: 5,
            game_id: checkmate_game.id
          ),

          King.new(
            position: 'e6',
            color: 'white',
            position_index: 29,
            game_id: checkmate_game.id
          )
        ]
        checkmate_game.update_pieces(pieces)

        expect(checkmate_game.checkmate?(checkmate_game.pieces, 'black')).to be true
      end
    end

    context 'when the king is not in checkmate' do
      it 'returns false' do
        expect(checkmate_game.checkmate?(checkmate_game.pieces, 'black')).to be false
      end
    end
  end

  describe 'stalemate?' do
    let(:game) { Game.create }
    context 'when there are no valid moves and the king is safe' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:no_valid_moves?).and_return(true)
        allow_any_instance_of(King).to receive(:king_is_safe?).and_return(true)

        expect(game.stalemate?(game.pieces, 'white')).to be true
      end
    end

    context 'when there are insufficient_pieces' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:insufficient_pieces?)
          .and_return(true)

        expect(game.stalemate?(game.pieces, 'white')).to be true
      end
    end

    context 'when there is a three_fold_repitition' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:three_fold_repitition?)
          .and_return(true)

        expect(game.stalemate?(game.pieces, 'white')).to be true
      end
    end
  end

  describe 'no_valid_moves?' do
    context 'when there are valid moves available' do
      it 'returns false' do
        game = Game.create
        expect(game.no_valid_moves?(game.pieces, 'white')).to be false
      end
    end

    context 'when there are no valid moves available' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:add_pieces)
          .and_return([])

        game = Game.new
        expect(game.no_valid_moves?(game.pieces, 'white')).to be true
      end
    end
  end
end
