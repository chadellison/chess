require 'rails_helper'

RSpec.describe Piece, type: :model do
  it 'belongs to a game' do
    piece = Piece.new(
      position: 'a2',
      piece_type: 'knight',
      color: 'white',
      position_index: Faker::Number.number(2)
    )
    game = Game.new
    game.pieces << piece

    expect(piece.game).to eq game
  end

  describe 'move_logic methods' do
    describe '#moves_up' do
      it 'returns an array of all possible moves up given a position' do
        position = 'f3'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )

        expected = ['f4', 'f5', 'f6', 'f7', 'f8']

        expect(piece.moves_up).to eq expected
      end
    end

    describe '#moves_down' do
      it 'returns an array of all possible moves down given a position' do
        position = 'f3'

        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['f2', 'f1']

        expect(piece.moves_down).to eq expected
      end
    end

    describe '#moves_left' do
      it 'returns an array of all possible moves left given a position' do
        position = 'f3'

        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['e3', 'd3', 'c3', 'b3', 'a3']

        expect(piece.moves_left).to eq expected
      end
    end

    describe '#moves_right' do
      it 'returns an array of all possible moves right given a position' do
        position = 'f3'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['g3', 'h3']

        expect(piece.moves_right).to eq expected
      end
    end

    describe '#moves_for_rook' do
      it 'returns an array of all possible moves for a rook in a given position' do
        position = 'd4'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                    'e4', 'f4', 'g4', 'h4']

        expect(piece.moves_for_rook).to eq expected
      end
    end

    describe '#moves_for_bishop' do
      it 'returns an array of all possible moves for a bishop in a given position' do
        position = 'd4'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['e5', 'f6', 'g7', 'h8', 'c5', 'b6', 'a7', 'c3', 'b2', 'a1',
                    'e3', 'f2', 'g1']

        expect(piece.moves_for_bishop).to eq expected
      end
    end

    describe '#extract_diagonals' do
      it 'returns an array of each set\'s first coordinate\'s column and second corrdinate\'s row' do
        piece = Piece.new(
          position: 'a2',
          piece_type: 'rook',
          color: 'black'
        )
        expect(piece.extract_diagonals([['b2', 'a3']])).to eq ['b3']
      end
    end

    describe '#moves_for_queen' do
      it 'returns an array of all possible moves for a queen in a given position' do
        position = 'd4'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                    'e4', 'f4', 'g4', 'h4', 'e5', 'f6', 'g7', 'h8', 'c5', 'b6',
                    'a7', 'c3', 'b2', 'a1', 'e3', 'f2', 'g1']

        expect(piece.moves_for_queen).to eq expected
      end
    end

    describe '#moves_for_king' do
      it 'returns an array of all possible moves for a king in a given position' do
        position = 'd4'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['d5', 'd3', 'c4', 'e4', 'e5', 'c5', 'c3', 'e3', 'b4', 'f4']

        expect(piece.moves_for_king).to eq expected
      end
    end

    describe '#moves_for_knight' do
      it 'returns an array of all possible moves for a knight in a given position' do
        position = 'd4'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['b5', 'b3', 'f5', 'f3', 'c6', 'c2', 'e6', 'e2']

        expect(piece.moves_for_knight).to eq expected
      end
    end

    describe '#moves_for_pawn' do
      it 'returns an array of all possible moves for a pawn (of either color) in a given position' do
        position = 'd4'
        piece = Piece.new(
          position: position,
          piece_type: 'rook',
          color: 'black'
        )
        expected = ['d5', 'd6', 'd3', 'd2', 'c5', 'e5', 'c3', 'e3']

        expect(piece.moves_for_pawn).to eq expected
      end
    end

    describe '#remove_out_of_bounds_moves' do
      let(:piece) { Piece.new }

      it 'removes coordinates that are greater than 8 and less than 1' do
        actual = piece.remove_out_of_bounds_moves(['a0', 'a2', 'a9'])
        expect(actual).to eq ['a2']
      end

      it 'removes coordinates that are greater than h and less than a' do
        actual = piece.remove_out_of_bounds_moves(['`0', 'a2', 'i9'])
        expect(actual).to eq ['a2']
      end

      it 'does not remove coordinates that are within bounds' do
        actual = piece.remove_out_of_bounds_moves(['a1', 'a2', 'a3'])
        expect(actual).to eq ['a1', 'a2', 'a3']
      end
    end

    describe '#vertical_collision?' do
      it 'returns true when there is a piece above in the path of the destination' do
        piece = Piece.new(position: 'a1')
        actual = piece.vertical_collision?('a8', ['a4'])
        expect(actual).to eq true
      end

      it 'returns true when there is a piece below in the path of the destination' do
        piece = Piece.new(position: 'b8')
        actual = piece.vertical_collision?('b1', ['b4'])
        expect(actual).to eq true
      end

      it 'returns false when there is no piece in the path of the destination' do
        piece = Piece.new(position: 'b8')
        actual = piece.vertical_collision?('b7', ['b4'])
        expect(actual).to eq false
      end
    end

    describe '#horizontal_collision?' do
      context 'when a piece is in the way of the move path of another' do
        let(:piece) {
          Piece.new(position: 'a1', piece_type: 'rook')
        }

        it 'returns true' do
          occupied_spaces = ['d1']
          expect(piece.horizontal_collision?('e1', occupied_spaces)).to be true
        end
      end

      context 'when a piece is not in the way of another' do
        let(:piece) {
          Piece.new(position: 'f1', piece_type: 'rook')
        }

        it 'returns false' do
          occupied_spaces = ['d1']
          expect(piece.horizontal_collision?('e1', occupied_spaces)).to be false
        end
      end
    end

    describe '#diagonal_collision?' do
      xit 'returns an array of all possible moves for a pawn (of either color) in a given position' do
      end
    end

    describe '#valid_move_path' do
      context 'when the move path is valid for a vertical move' do
        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook')
          expect(piece.valid_move_path?('a7', ['a8', 'a2'])).to be true
        end

        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'a7', piece_type: 'rook')
          expect(piece.valid_move_path?('a3', ['a8', 'a2'])).to be true
        end
      end

      context 'when the move path not is valid for a vertical move' do
        it 'returns false' do
          piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook')
          expect(piece.valid_move_path?('a7', ['a8', 'a2', 'a5'])).to be false
        end

        it 'returns false' do
          piece = Piece.new(color: 'white', position: 'a7', piece_type: 'rook')
          expect(piece.valid_move_path?('a3', ['a8', 'a2', 'a5'])).to be false
        end
      end

      context 'when the move path is valid for a horizontal move' do
        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook')
          expect(piece.valid_move_path?('e3', ['a8', 'a2'])).to be true
        end

        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'e7', piece_type: 'rook')
          expect(piece.valid_move_path?('a7', ['a8', 'a2'])).to be true
        end
      end

      context 'when the move path not is valid for a vertical move' do
        it 'returns false' do
          piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook')
          expect(piece.valid_move_path?('e3', ['a8', 'c3', 'a5'])).to be false
        end

        it 'returns false' do
          piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook')
          expect(piece.valid_move_path?('e3', ['a8', 'c3', 'a5'])).to be false
        end
      end

      context 'when the move path is valid for a diagonal move' do
        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'd4', piece_type: 'bishop')
          expect(piece.valid_move_path?('f6', ['a8', 'a2'])).to be true
        end

        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'f6', piece_type: 'rook')
          expect(piece.valid_move_path?('d4', ['a8', 'a2'])).to be true
        end
      end

      context 'when the move path is valid for a diagonal move' do
        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'f3', piece_type: 'bishop')
          expect(piece.valid_move_path?('d5', ['a8', 'a2'])).to be true
        end

        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'd5', piece_type: 'rook')
          expect(piece.valid_move_path?('f3', ['a8', 'a2'])).to be true
        end
      end

      context 'when the move path not is valid for a diagonal move' do
        it 'returns false' do
          piece = Piece.new(color: 'white', position: 'f3', piece_type: 'rook')
          expect(piece.valid_move_path?('d5', ['a8', 'e4', 'a5'])).to be false
        end

        it 'returns false' do
          piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook')
          expect(piece.valid_move_path?('e7', ['a8', 'd6', 'a5'])).to be false
        end
      end

      context 'when the piece is a knight or a king' do
        it 'returns true' do
          piece = Piece.new(color: 'white', position: 'f3', piece_type: 'knight')
          expect(piece.valid_move_path?('d4', ['a8', 'e4', 'a5'])).to be true
        end

        it 'returns false' do
          piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook')
          expect(piece.valid_move_path?('a4', ['a8', 'd6', 'a5'])).to be true
        end
      end
    end

    describe '#valid_destination' do
      context 'when the destination is a different color than the piece moving' do
        let(:game) { Game.create }

        it 'returns true' do

          piece = game.pieces.create(color: 'white', position: 'a3', piece_type: 'rook')
          game.pieces.create(color: 'black', position: 'a4', piece_type: 'rook')

          expect(piece.valid_destination?('a4', game.pieces)).to be true
        end
      end

      context 'when the destination is empty' do
        let(:game) { Game.create }
        it 'returns true' do
          piece = game.pieces.create(
            color: 'white',
            position: 'a3',
            piece_type: 'rook',
            position_index: 25
          )
          game.pieces.create(
            color: 'black',
            position: 'a7',
            piece_type: 'rook',
            position_index: 32
          )

          expect(piece.valid_destination?('a4', game.pieces)).to be true
        end
      end

      context 'when the destination is occupied by an allied piece' do
        let(:game) {
          Game.create
        }

        it 'returns false' do
          piece = game.pieces.find_by(position_index: 17)

          game.pieces.find_by(position_index: 9).update(
            color: 'white',
            position: 'a7',
            piece_type: 'rook',
            position_index: 32
          )

          expect(piece.valid_destination?('a7', game.pieces)).to be false
        end
      end

      context 'when the destination is the opponent king' do
        let(:game) {
          Game.create
        }

        it 'returns true' do
          piece = game.pieces.find_by(position_index: 26)
          game.pieces.find_by(position_index: 5).update(position: 'd6')
          piece.update(position: 'e4')

          expect(piece.valid_destination?('d6', game.pieces)).to be true
        end
      end
    end

    describe '#king_is_safe?' do
      context 'when the king is not in check' do
        let(:game) {
          Game.create
        }

        it 'returns true' do
          piece = game.pieces.find_by(position_index: 25)
          piece.update(position: 'a3')

          game.pieces.find_by(position_index: 5).update(position: 'd6')

          expect(piece.king_is_safe?('black', game.pieces)).to be true
        end
      end

      context 'when the king is in check' do
        let(:game) {
          Game.create
        }

        it 'returns false' do
          piece = game.pieces.find_by(position_index: 25)
          piece.update(position: 'd4')

          game.pieces.find_by(position_index: 5).update(position: 'd6')
          expect(piece.king_is_safe?('black', game.pieces)).to be false
        end
      end

      context 'when the king is in check from a diagonal threat' do
        let(:game) {
          Game.create
        }

        it 'returns false' do
          piece = game.pieces.find_by(position_index: 30)
          piece.update(position: 'h3')

          game.pieces.find_by(position_index: 5).update(position: 'e6')
          expect(piece.king_is_safe?('black', game.pieces)).to be false
        end
      end

      context 'when the king is in check from a diagonal one space away' do
        let(:game) {
          Game.create
        }

        it 'returns false' do
          piece = game.pieces.find_by(position_index: 30)
          piece.update(position: 'f5')

          game.pieces.find_by(position_index: 5).update(position: 'e6')
          expect(piece.king_is_safe?('black', game.pieces)).to be false
        end
      end

      context 'when the king is in check from a knight' do
        let(:game) {
          Game.create
        }

        it 'returns false' do
          game.pieces.find_by(position_index: 2).update(position: 'f3')

          piece = game.pieces.find_by(color: 'white', piece_type: 'king')
          expect(piece.king_is_safe?('white', game.pieces)).to be false
        end
      end
    end

    describe '#pieces_with_next_move' do
      xit 'test' do
      end
    end

    describe 'valid_moves' do
      context 'when the king is in check' do
        it 'returns all moves to get the king out of check' do
          allow_any_instance_of(Game).to receive(:add_pieces).and_return(nil)

          game = Game.create

          piece = game.pieces.create(
            piece_type: 'king',
            color: 'black',
            position_index: 5,
            position: 'e8'
          )
          game.pieces.create(
            piece_type: 'king',
            color: 'white',
            position_index: 29,
            position: 'e1'
          )

          game.pieces.create(
            piece_type: 'queen',
            color: 'white',
            position_index: 28,
            position: 'e2'
          )

          expected = ['d8', 'f8', 'd7', 'f7']

          expect(piece.valid_moves).to eq expected
        end
      end

      context 'when the king must kill a piece to get out of check' do
        it 'returns all moves to get the king out of check' do
          allow_any_instance_of(Game).to receive(:add_pieces).and_return(nil)

          game = Game.create

          piece = game.pieces.create(
            piece_type: 'king',
            color: 'black',
            position_index: 5,
            position: 'e8'
          )
          game.pieces.create(
            piece_type: 'king',
            color: 'white',
            position_index: 29,
            position: 'e1'
          )

          game.pieces.create(
            piece_type: 'queen',
            color: 'white',
            position_index: 28,
            position: 'e7'
          )

          expected = ['e7']

          expect(piece.valid_moves).to eq expected
        end
      end

      context 'when the king is in checkmate' do
        it 'returns an empty array' do
          allow_any_instance_of(Game).to receive(:add_pieces).and_return(nil)
          game = Game.create
          piece = game.pieces.create(
            piece_type: 'king',
            color: 'black',
            position_index: 5,
            position: 'e8'
          )
          game.pieces.create(
            piece_type: 'king',
            color: 'white',
            position_index: 29,
            position: 'e1'
          )

          game.pieces.create(
            piece_type: 'queen',
            color: 'white',
            position_index: 28,
            position: 'e7'
          )

          game.pieces.create(
            piece_type: 'knight',
            color: 'white',
            position_index: 26,
            position: 'd5'
          )

          expected = []

          expect(piece.valid_moves).to eq expected
        end
      end

      context 'when there are pieces blocking all of a piece\'s moves' do
        it 'returns an empty array' do
          game = Game.create

          piece = Piece.find_by(position: 'd1')

          expect(piece.valid_moves).to eq []
        end
      end

      context 'when there are pieces blocking all of a piece\'s moves except one' do
        it 'returns one position' do
          game = Game.create

          game.pieces.find_by(position: 'd7').update(position: 'd6')
          piece = game.pieces.find_by(position: 'd8')

          expect(piece.valid_moves).to eq ['d7']
        end
      end
    end

    describe '#handle_moved_two' do
      context 'when the piece is a pawn and has moved two' do
        let(:game) { Game.create }

        it 'updates the moved_two property to true' do
          piece = game.pieces.find_by(position: 'd2')

          piece.handle_moved_two('d4')

          expect(piece.moved_two).to be true
        end
      end

      context 'when the piece has not moved two' do
        let(:game) { Game.create }

        before do
          game.pieces.where(piece_type: 'pawn').update(moved_two: true)
        end

        it 'updates the moved_two property of all other pawns to false' do
          piece = game.pieces.find_by(position: 'd2')

          piece.handle_moved_two('d3')

          moved_twoProperties = game.pieces.where(piece_type: 'pawn').pluck(:moved_two)
          expect(moved_twoProperties.all?).to be false
        end
      end
    end

    describe '#valid_for_piece' do
      context 'when a king can castle' do
        let(:game) { Game.create }
        before do
          game.pieces.where(position: ['f1', 'g1']).destroy_all
        end

        it 'returns true when the next move is a castle' do
          piece = game.pieces.find_by(position_index: 29)
          expect(piece.valid_for_piece?('g1', game.pieces)).to be true
        end
      end

      context 'when a king cannot castle due to having moved' do
        let(:game) { Game.create }

        before do
          game.pieces.where(position: ['f1', 'g1']).destroy_all
        end

        it 'returns false when the next move is a castle' do
          piece = game.pieces.find_by(position_index: 29)
          piece.update(has_moved: true)

          expect(piece.valid_for_piece?('g1', game.pieces)).to be false
        end
      end

      context 'when a king cannot castle due to it\'s rook moving' do
        let(:game) { Game.create }

        before do
          game.pieces.where(position: ['f1', 'g1']).destroy_all
        end

        it 'returns false when the next move is a castle' do
          rook = game.pieces.find_by(position_index: 32)
          rook.update(has_moved: true)

          king = game.pieces.find_by(position_index: 29)

          expect(king.valid_for_piece?('g1', game.pieces)).to be false
        end
      end

      context 'when a king cannot castle due to it\'s rook not being present' do
        let(:game) { Game.create }

        before do
          game.pieces.where(position: ['f1', 'g1', 'h1']).destroy_all
        end

        it 'returns false when the next move is a castle' do
          king = game.pieces.find_by(position_index: 29)

          expect(king.valid_for_piece?('g1', game.pieces.reload)).to be false
        end
      end

      context 'when a king cannot castle due to being in check' do
        let(:game) { Game.create }

        before do
          game.pieces.where(position: ['e2', 'f1', 'g1', 'e7']).destroy_all
          game.pieces.find_by(position_index: 4).update(position: 'e7')
        end

        it 'returns false when the next move is a castle' do
          king = game.pieces.find_by(position_index: 29)

          expect(king.valid_for_piece?('g1', game.pieces)).to be false
        end
      end

      context 'when a king cannot castle due to moving through check' do
        it 'returns false when the next move is a castle' do
          allow_any_instance_of(Game).to receive(:add_pieces)

          game_pieces = [
            Piece.create(piece_type: 'rook', position: 'd8', color: 'black'),
            Piece.create(piece_type: 'king', position: 'e1', color: 'white'),
            Piece.create(piece_type: 'rook', position: 'a8', color: 'white')
          ]

          game = Game.create
          game.pieces = game_pieces
          king = game.pieces.find_by(piece_type: 'king')
          expect(king.valid_for_piece?('c1', game.pieces)).to be false
        end
      end
    end

    describe '#castle?' do
      xit 'test' do
      end
    end

    describe '#can_en_pessant?' do
      let(:game) { Game.create }

      let(:piece) {
        game.pieces.find_by(position: 'c2')
      }

      context 'when the adjacent peice is an ally' do
        before do
          game.pieces.find_by(position: 'd2').update(position: 'd4', moved_two: true)
          piece.update(position: 'c4')
        end

        it 'returns false' do
          expect(piece.can_en_pessant?('d5', game.pieces.reload)).to be false
        end
      end
    end

    describe '#valid_for_pawn?' do
      context 'when the pawn moves one space forward and the space is open' do
        let(:game) { Game.create }

        it 'returns true' do
          piece = game.pieces.find_by(position: 'd2')
          expect(piece.valid_for_pawn?('d3', game.pieces)).to be true
        end
      end

      context 'when the pawn moves one space forward and the space is not open' do
        let(:game) { Game.create }

        before do
          game.pieces.find_by(position: 'd2').update(position: 'd4')
          game.pieces.find_by(position: 'd7').update(position: 'd5')
        end

        it 'returns false' do
          piece = game.pieces.find_by(position: 'd4')
          expect(piece.valid_for_pawn?('d5', game.pieces)).to be false
        end
      end

      context 'when the black pawn moves one space forward and the space is open' do
        let(:game) { Game.create }

        it 'returns true' do
          piece = game.pieces.find_by(position: 'd7')
          expect(piece.valid_for_pawn?('d6', game.pieces)).to be true
        end
      end

      context 'when the black pawn moves one space forward and the space is not open' do
        let(:game) { Game.create }

        before do
          game.pieces.find_by(position: 'd7').update(position: 'd5')
          game.pieces.find_by(position: 'd2').update(position: 'd4')
        end

        it 'returns false' do
          piece = game.pieces.find_by(position: 'd5')
          expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
        end
      end
    end

    context 'when the pawn moves two spaces forward and the space is open' do
      let(:game) { Game.create }

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd2')
        expect(piece.valid_for_pawn?('d4', game.pieces)).to be true
      end
    end

    context 'when the pawn moves two spaces forward and the space is not open' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd7').update(position: 'd4')
      end

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd2')
        expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
      end
    end

    context 'when the pawn moves two spaces forward and the pawn has already moved' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(has_moved: true)
      end

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd2')
        expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
      end
    end

    context 'when the pawn attempts to move in the wrong direction' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(position: 'd4')
      end

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd4')
        expect(piece.valid_for_pawn?('d3', game.pieces)).to be false
      end
    end

    context 'when the pawn attempts to capture a piece in the wrong direction' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(position: 'd4')
        game.pieces.find_by(position: 'e7').update(position: 'e3')
      end

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd4')
        expect(piece.valid_for_pawn?('e3', game.pieces)).to be false
      end
    end

    context 'when the pawn attempts to capture a piece on an empty square' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(position: 'd4')
        game.pieces.find_by(position: 'e7').update(position: 'e5')
      end

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd4')
        expect(piece.valid_for_pawn?('c5', game.pieces)).to be false
      end
    end

    context 'when the pawn attempts to capture a piece on an occupied square' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(position: 'd4')
        game.pieces.find_by(position: 'e7').update(position: 'e5')
      end

      it 'returns true' do
        piece = game.pieces.find_by(position: 'd4')
        expect(piece.valid_for_pawn?('e5', game.pieces)).to be true
      end
    end

    context 'when the pawn attempts to en passant a piece correctly' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(position: 'd5')
        game.pieces.find_by(position: 'e7')
            .update(position: 'e5', moved_two: true)
      end

      it 'returns true' do
        piece = game.pieces.find_by(position: 'd5')
        expect(piece.valid_for_pawn?('e6', game.pieces)).to be true
      end
    end

    context 'when the pawn attempts to en passant a piece that has not moved_two' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(position: 'd5')
        game.pieces.find_by(position: 'e7').update(position: 'e5')
      end

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd5')
        expect(piece.valid_for_pawn?('e6', game.pieces)).to be false
      end
    end

    context 'when the pawn attempts to en passant in the wrong direction' do
      let(:game) { Game.create }

      before do
        game.pieces.find_by(position: 'd2').update(position: 'd5')
        game.pieces.find_by(position: 'e7').update(position: 'e5', moved_two: true)
      end

      it 'returns false' do
        piece = game.pieces.find_by(position: 'd5')
        expect(piece.valid_for_pawn?('e4', game.pieces)).to be false
      end
    end

    describe '#advance_pawn?' do
      let(:game) { Game.create }

      let(:piece) {
        game.pieces.create(
          piece_type: 'pawn',
          color: 'white',
          position_index: 20,
          position: 'd4'
        )
      }

      context 'when a piece is in the way of the pawn' do
        before do
          game.pieces.find_by(position: 'd7').update(position: 'd5')
        end

        it 'returns false' do
          expect(piece.advance_pawn?('d5', game.pieces.reload)).to be false
        end
      end

      context 'when a piece is not in the way of the pawn' do
        it 'returns true' do
          expect(piece.advance_pawn?('d5', game.pieces)).to be true
        end
      end
    end

    describe '#valid_move?' do
      let(:game) { Game.create }

      let(:piece) {
        game.pieces.create(
          piece_type: 'king',
          color: 'black',
          position_index: 13,
          position: 'e7'
        )
      }

      it 'calls valid_move_path?' do
        expect_any_instance_of(Piece).to receive(:valid_move_path?)
          .with('e5', piece.game.pieces.pluck(:position))
        piece.valid_move?('e5')
      end

      it 'calls valid_destination?' do
        expect_any_instance_of(Piece).to receive(:valid_destination?)
          .with('e5', piece.game.pieces)

        piece.valid_move?('e5')
      end

      it 'calls valid_for_piece?' do
        expect_any_instance_of(Piece).to receive(:valid_for_piece?)
          .with('e5', piece.game.pieces)

        piece.valid_move?('e5')
      end

      it 'calls king_is_safe?' do
        expect_any_instance_of(Piece).to receive(:king_is_safe?)
          .with('black', piece.pieces_with_next_move('e5'))

        piece.valid_move?('e5')
      end
    end

    describe '#forward_two?' do
      context 'when the piece has moved down two' do
        it 'returns true' do
          piece = Piece.new(position: 'b7')
          expect(piece.forward_two?('b5')).to be true
        end
      end

      context 'when the piece has moved up two' do
        it 'returns ture' do
          piece = Piece.new(position: 'a2')
          expect(piece.forward_two?('a4')).to be true
        end
      end

      context 'when the piece has not moved down two or up two' do
        it 'returns false' do
          piece = Piece.new(position: 'a2')
          expect(piece.forward_two?('a3')).to be false
        end
      end
    end
  end
end
