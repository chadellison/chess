require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'has many pieces' do
    piece = Piece.new(
      piece_type: 'rook',
      color: 'black',
      position: 'a2'
    )

    game = Game.new
    game.pieces << piece

    expect(game.pieces).to eq [piece]
  end

  it 'has many game_setups' do
    game_setup = GameSetup.new

    game = Game.new
    game.game_setups << game_setup

    expect(game.game_setups).to eq [game_setup]
  end

  it 'has many setups' do
    setup = Setup.new

    game = Game.new
    game.setups << setup

    expect(game.setups).to eq [setup]
  end

  describe 'move' do
    it 'updates the moved piece\'s position and has_moved property' do
      game = Game.create
      game.move(9, 'a3')

      actual = game.pieces.find_by(position_index: 9)
      expect(actual.position).to eq 'a3'
      expect(actual.has_moved).to be true
    end

    it 'calls create_notation' do
      expect_any_instance_of(Game).to receive(:update_notation)
        .with(9, 'a3', '')
      game = Game.create
      game.move(9, 'a3')
    end

    it 'calls update_board' do
      expect_any_instance_of(Game).to receive(:update_board)
      game = Game.create
      game.move(9, 'a3')
    end
  end

  describe 'update_board' do
    it 'calls update_piece' do
      game = Game.create
      piece = game.pieces.find_by(position_index: 9)
      expect_any_instance_of(Game).to receive(:update_piece)
        .with(piece, 'a3', '')
      game.move(9, 'a3')
    end

    it 'creates a move position_signature of the current board positions' do
      game = Game.create
      game.update_board

      expected = '1a8.2b8.3c8.4d8.5e8.6f8.7g8.8h8.9a7.10b7.11c7.12d7.13e7.14f7.15g7.16h7.17a2.18b2.19c2.20d2.21e2.22f2.23g2.24h2.25a1.26b1.27c1.28d1.29e1.30f1.31g1.32h1'

      actual = game.setups.first.position_signature
      expect(actual).to eq expected
    end

    it 'creates a setup on the game if it does not already exist' do
      game = Game.create

      expect { game.update_board }.to change { game.setups.count }.by(1)
    end

    context 'when the position is occuppied by an opponent piece' do
      xit 'deletes that piece from the game' do
      end
    end
  end

  describe 'handle_en_passant' do
    context 'when the piece type is a pawn ' do
      it 'test' do
      end
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

  describe 'after_commits' do
    describe 'add_pieces' do
      it 'adds 32 pieces to a game' do
        expect { Game.create }.to change { Piece.count }.by(32)
      end
    end
  end

  describe 'notation logic methods' do
    describe 'create_move_from_notation' do
      xit 'test' do
      end
    end

    describe 'move_from_castle' do
      xit 'test' do
      end
    end

    describe 'find_piece_type' do
      xit 'test' do
      end
    end

    describe 'move_from_start' do
      xit 'test' do
      end
    end

    describe 'find_piece' do
      xit 'test' do
      end
    end

    describe 'move_from_crossed_pawn' do
      xit 'test' do
      end
    end

    describe 'create_notation' do
      context 'for a pawn move' do
        it 'returns the notation' do
          game = Game.create
          actual = game.create_notation(20, 'd4', '')
          expect(actual).to eq 'd4.'
        end
      end

      context 'when a pawn kills another piece' do
        it 'returns the notation' do
          game = Game.create
          game.pieces.find_by(position: 'e7').update(position: 'e5')
          game.pieces.find_by(position: 'd2').update(position: 'd4')
          actual = game.create_notation(20, 'e5', '')
          expect(actual).to eq 'dxe5.'
        end
      end

      context 'for a castle' do
        it 'calls the notation' do
          game = Game.create
          game.pieces.find_by(position: 'f1').update(position: '')
          game.pieces.find_by(position: 'g1').update(position: '')

          expect_any_instance_of(Game).to receive(:castle_notation)
            .with('g1')
          game.create_notation(29, 'g1', '')
        end

        context 'on the king side' do
          it 'returns the notation' do
            game = Game.create
            game.pieces.find_by(position: 'f1').update(position: '')
            game.pieces.find_by(position: 'g1').update(position: '')
            actual = game.create_notation(29, 'g1', '')
            expect(actual).to eq 'O-O.'
          end
        end

        context 'on the queen side' do
          it 'returns the notation' do
            game = Game.create
            game.pieces.find_by(position: 'd1').update(position: '')
            game.pieces.find_by(position: 'c1').update(position: '')
            game.pieces.find_by(position: 'b1').update(position: '')
            actual = game.create_notation(29, 'c1', '')
            expect(actual).to eq 'O-O-O.'
          end
        end
      end

      context 'for a knight' do
        it 'returns the notation' do
          game = Game.create
          actual = game.create_notation(26, 'c3', '')
          expect(actual).to eq 'Nc3.'
        end
      end

      context 'for a knight when both knights can move on a given position' do
        it 'returns the notation' do
          game = Game.create
          game.pieces.find_by(position: 'b1').update(position: 'c3')
          game.pieces.find_by(position: 'g1').update(position: 'e3')

          knight_on_c = game.create_notation(26, 'd5', '')
          expect(knight_on_c).to eq 'Ncd5.'

          knight_on_e = game.create_notation(31, 'd5', '')
          expect(knight_on_e).to eq 'Ned5.'
        end
      end

      context 'for a rook' do
        it 'returns the notation' do
          game = Game.create
          game.pieces.find_by(position: 'a2').update(position: '')
          actual = game.create_notation(25, 'a6', '')
          expect(actual).to eq 'Ra6.'
        end
      end

      context 'for a rook when two rooks are on the same column' do
        it 'returns the notation' do
          game = Game.create
          game.pieces.find_by(position: 'a1').update(position: 'a3')
          game.pieces.find_by(position: 'h1').update(position: 'h3')
          actual = game.create_notation(25, 'd3', '')
          expect(actual).to eq 'Rad3.'
        end
      end

      context 'for a rook when two rooks are on the same row' do
        it 'returns the notation' do
          game = Game.create
          game.pieces.find_by(position: 'a1').update(position: 'a3')
          game.pieces.find_by(position: 'h1').update(position: 'h3')
          actual = game.create_notation(32, 'd3', '')
          expect(actual).to eq 'Rhd3.'
        end
      end

      context 'for a crossed pawn' do
        it 'returns the notation' do
          allow_any_instance_of(Game).to receive(:add_pieces)
          game = Game.create
          game.pieces.create(
            position_index: 17,
            position: 'a7',
            piece_type: 'pawn',
            color: 'white'
          )

          game.pieces.create(
            position_index: 29,
            position: 'e1',
            piece_type: 'king',
            color: 'white'
          )

          game.pieces.create(
            position_index: 5,
            position: 'e8',
            piece_type: 'king',
            color: 'black'
          )
          actual = game.create_notation(17, 'a8', 'queen')
          expect(actual).to eq 'a8=Q.'
        end
      end

      context 'for a crossed pawn that captures a piece' do
        it 'returns the notation' do
          game = Game.create
          game.pieces.find_by(position_index: 17).update(position: 'a7')
          game.pieces.find_by(position_index: 9).destroy
          game.pieces.find_by(position_index: 1).destroy
          actual = game.create_notation(17, 'b8', 'queen')
          expect(actual).to eq 'axb8=Q.'
        end
      end
    end

    describe 'start_notation' do
      it 'calls matching_pieces' do
        game = Game.new
        piece = Piece.new(piece_type: 'pawn', color: 'white')
        expect_any_instance_of(Game).to receive(:matching_pieces)
          .with('pawn', 'white','d4').and_return([piece])

          game.start_notation(piece, 'd4')
      end

      context 'when only one piece can move to the destination' do
        it 'returns an empty string' do
          game = Game.new
          piece = Piece.new(piece_type: 'pawn', color: 'white')
          allow_any_instance_of(Game).to receive(:matching_pieces)
            .with('pawn', 'white','d4').and_return([piece])

          actual = game.start_notation(piece, 'd4')
          expect(actual).to eq ''
        end
      end

      context 'when more than one piece can move to the destination' do
        it 'calls column_is_unique' do
          game = Game.new
          piece = Piece.new(piece_type: 'pawn', color: 'white', position: 'd2')
          allow_any_instance_of(Game).to receive(:matching_pieces)
            .with('pawn', 'white','d4').and_return([piece, piece])

          expect_any_instance_of(Game).to receive(:column_is_unique?)
            .with([piece, piece], 'd2')
          game.start_notation(piece, 'd4')
        end
      end
    end

    describe 'capture_notation' do
      context 'when no pieces are present on the destination' do
        it 'returns an empty string' do
          allow_any_instance_of(Game).to receive(:add_pieces)

          game = Game.create
          piece = Piece.new(position: 'd4')
          actual = game.capture_notation('abc123', piece, 'd5')
          expect(actual).to eq ''
        end
      end

      context 'when a piece is present on the destination' do
        it 'returns an x' do
          allow_any_instance_of(Game).to receive(:add_pieces)

          game = Game.create
          piece1 = game.pieces.create(position: 'd4')
          piece2 = game.pieces.create(position: 'c3')
          actual = game.capture_notation('abc123', piece1, 'c3')
          expect(actual).to eq 'x'
        end
      end

      context 'when a piece is present on the destination and the notation is blank' do
        it 'returns a the column and an x' do
          allow_any_instance_of(Game).to receive(:add_pieces)

          game = Game.create
          piece1 = game.pieces.create(position: 'd4')
          piece2 = game.pieces.create(position: 'c3')
          actual = game.capture_notation('', piece1, 'c3')
          expect(actual).to eq 'dx'
        end
      end
    end

    describe 'castle_notation' do
      context 'on the king side' do
        it 'returns O-O.' do
          game = Game.create
          game.pieces.find_by(position: 'f1').update(position: '')
          game.pieces.find_by(position: 'g1').update(position: '')
          actual = game.create_notation(29, 'g1', '')
          expect(actual).to eq 'O-O.'
        end
      end

      context 'for a castle on the queen side' do
        it 'returns O-O-O.' do
          game = Game.create
          game.pieces.find_by(position: 'd1').update(position: '')
          game.pieces.find_by(position: 'c1').update(position: '')
          game.pieces.find_by(position: 'b1').update(position: '')
          actual = game.create_notation(29, 'c1', '')
          expect(actual).to eq 'O-O-O.'
        end
      end
    end

    describe 'matching_pieces' do
      it 'returns all the pieces that can move on the same square' do
        game = Game.create
        knight1 = game.pieces.find_by(position: 'b1', color: 'white', piece_type: 'knight')
        knight2 = game.pieces.find_by(position: 'g1', color: 'white', piece_type: 'knight')

        knight1.update(position: 'e3')
        knight2.update(position: 'c3')

        actual = game.matching_pieces('knight', 'white', 'd5')
        expect(actual.pluck(:id).sort).to eq [knight1.id, knight2.id].sort
      end
    end

    describe 'column_is_unique?' do
      context 'when the pieces are on the same column' do
        it 'returns true' do
          game = Game.create
          rook1 = game.pieces.find_by(position: 'a1', color: 'white')
          rook2 = game.pieces.find_by(position: 'h1', color: 'white')

          rook1.update(position: 'e3')
          rook2.update(position: 'e6')

          actual = game.column_is_unique?([rook1, rook2], 'e3')
          expect(actual).to be false
        end
      end

      context 'when the pieces are not on the same column' do
        it 'returns true' do
          game = Game.create
          knight1 = game.pieces.find_by(position: 'b1', color: 'white')
          knight2 = game.pieces.find_by(position: 'g1', color: 'white')

          knight1.update(position: 'e3')
          knight2.update(position: 'c3')

          actual = game.column_is_unique?([knight1, knight2], 'e3')
          expect(actual).to be true
        end
      end
    end
  end
end
