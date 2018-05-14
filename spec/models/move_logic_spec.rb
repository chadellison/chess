require 'rails_helper'

RSpec.describe MoveLogic, type: :module do
  describe 'moves_for_rook' do
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

  describe 'moves_up' do
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

  describe 'moves_down' do
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

  describe 'moves_left' do
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

  describe 'moves_right' do
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

  describe 'moves_for_bishop' do
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

  describe 'extract_diagonals' do
    it 'returns an array of each set\'s first coordinate\'s column and second corrdinate\'s row' do
      piece = Piece.new(
        position: 'a2',
        piece_type: 'rook',
        color: 'black'
      )
      expect(piece.extract_diagonals([['b2', 'a3']])).to eq ['b3']
    end
  end

  describe 'moves_for_queen' do
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

  describe 'moves_for_king' do
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

  describe 'moves_for_knight' do
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

  describe 'moves_for_pawn' do
    it 'returns an array of all possible moves for a pawn (of either color) in a given position' do
      piece = Piece.new(
        position: 'd4',
        piece_type: 'rook',
        color: 'black'
      )
      expected = ['d3', 'd2', 'c3', 'e3']

      expect(piece.moves_for_pawn).to eq expected
    end
  end

  describe 'remove_out_of_bounds_moves' do
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

  describe 'vertical_collision?' do
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

  describe 'horizontal_collision?' do
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

  describe 'diagonal_collision?' do
    before do
      allow_any_instance_of(Game).to receive(:add_pieces)
    end

    context 'when there is a diagonal collision' do
      it 'returns true' do
        game = Game.create
        piece = Piece.new(position: 'e3')

        expect(piece.diagonal_collision?('a7', ['b6'])).to be true
        expect(piece.diagonal_collision?('h6', ['g5'])).to be true
        expect(piece.diagonal_collision?('c1', ['d2'])).to be true
        expect(piece.diagonal_collision?('g1', ['f2'])).to be true
      end
    end

    context 'when there is not a diagonal collision' do
      it 'returns true' do
        game = Game.create
        piece = Piece.new(position: 'c3')

        expect(piece.diagonal_collision?('a1', [])).to be false
        expect(piece.diagonal_collision?('f6', ['e6'])).to be false
        expect(piece.diagonal_collision?('b4', ['b4'])).to be false
      end
    end
  end

  describe 'valid_move_path' do
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

  describe 'valid_destination' do
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

  describe 'king_is_safe?' do
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

  describe 'can_en_pessant?' do
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

  describe 'valid_for_pawn?' do
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
