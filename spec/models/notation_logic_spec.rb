require 'rails_helper'

RSpec.describe NotationLogic, type: :module do
  describe 'update_game_from_notation' do
    it 'test' do
    end
  end

  describe 'move_from_castle' do
    context 'when it is black\'s turn' do
      it 'calls update_game with the black king' do
        game = Game.create
        king = game.pieces.find_by(color: 'black', piece_type: 'king')

        expect_any_instance_of(Game).to receive(:update_game)
          .with(king, 'g8')

        game.move_from_castle('O-O', 'black')
      end
    end

    context 'when it is white\'s turn' do
      it 'calls update_game with the white king' do
        game = Game.create
        king = game.pieces.find_by(color: 'white', piece_type: 'king')

        expect_any_instance_of(Game).to receive(:update_game)
          .with(king, 'c1')

        game.move_from_castle('O-O-O', 'white')
      end
    end
  end

  describe 'find_piece_type' do
    context 'when the piece is K' do
      it 'returns king' do
        game = Game.new
        expect(game.find_piece_type('Kd4')).to eq 'king'
      end
    end

    context 'when the piece is Q' do
      it 'returns queen' do
        game = Game.new
        expect(game.find_piece_type('Qd4')).to eq 'queen'
      end
    end

    context 'when the piece is B' do
      it 'returns bishop' do
        game = Game.new
        expect(game.find_piece_type('Bd4')).to eq 'bishop'
      end
    end

    context 'when the piece is R' do
      it 'returns rook' do
        game = Game.new
        expect(game.find_piece_type('Rd4')).to eq 'rook'
      end
    end

    context 'when the piece is N' do
      it 'returns knight' do
        game = Game.new
        expect(game.find_piece_type('Nd4')).to eq 'knight'
      end
    end

    context 'when the piece is an empty string' do
      it 'returns pawn' do
        game = Game.new
        expect(game.find_piece_type('d4')).to eq 'pawn'
      end
    end
  end

  describe 'move_from_start' do
    it 'calls update_game with the piece that matches the start notation' do
      piece = Piece.new(position: 'b5')
      piece2 = Piece.new(position: 'c4')
      game = Game.new

      expect_any_instance_of(Game).to receive(:update_game)
        .with(piece, 'd4')

      game.move_from_start([piece, piece2], 'bd4')
    end
  end

  describe 'find_piece' do
    context 'when the pieces passed in is one' do
      it 'calls update_game' do
        piece = Piece.new
        pieces = [piece]
        game = Game.new

        expect_any_instance_of(Game).to receive(:update_game)
          .with(piece, 'd4')

        game.find_piece(pieces, 'd4', 'pawn')
      end
    end

    context 'when the pieces passed in is greater than one' do
      it 'calls move_from_start' do
        pieces = [Piece.new, Piece.new]
        game = Game.new

        expect_any_instance_of(Game).to receive(:move_from_start)
          .with(pieces, 'd4')

        game.find_piece(pieces, 'd4', 'pawn')
      end
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
