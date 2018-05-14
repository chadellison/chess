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

  describe 'moves_for_piece' do
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
      it 'returns false' do
        allow_any_instance_of(Game).to receive(:add_pieces)
        game = Game.create

        game_pieces = [
          Piece.create(piece_type: 'queen', position: 'e7', color: 'black', position_index: 4),
          Piece.create(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.create(piece_type: 'king', position: 'e1', color: 'white', position_index: 29),
          Piece.create(piece_type: 'rook', position: 'a8', color: 'white', position_index: 25)
        ]
        game.pieces = game_pieces
        king = game.pieces.find_by(position_index: 29)

        expect(king.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to moving through check' do
      it 'returns false when the next move is a castle' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game_pieces = [
          Piece.create(piece_type: 'rook', position: 'd8', color: 'black'),
          Piece.create(piece_type: 'king', position: 'e8', color: 'black'),
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

  describe 'castle?' do
    context 'when the king can castle' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game_pieces = [
          Piece.create(piece_type: 'rook', position: 'h8', color: 'black', position_index: 1),
          Piece.create(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.create(piece_type: 'king', position: 'e1', color: 'white', position_index: 29),
          Piece.create(piece_type: 'rook', position: 'a1', color: 'white', position_index: 25)
        ]

        game = Game.create
        game.pieces = game_pieces
        king = game.pieces.find_by(position_index: 29)
        expect(king.castle?('c1', game.pieces)).to be true
      end
    end

    context 'when the king cannot castle because the rook is not on the same row' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game_pieces = [
          Piece.create(piece_type: 'rook', position: 'd8', color: 'black'),
          Piece.create(piece_type: 'king', position: 'e1', color: 'white'),
          Piece.create(piece_type: 'rook', position: 'a8', color: 'white')
        ]

        game = Game.create
        game.pieces = game_pieces
        king = game.pieces.find_by(piece_type: 'king')
        expect(king.castle?('c1', game.pieces)).to be false
      end
    end

    context 'when the king cannot castle because the king has moved' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game_pieces = [
          Piece.create(piece_type: 'rook', position: 'h8', color: 'black', position_index: 1),
          Piece.create(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.create(piece_type: 'king', position: 'e1', color: 'white', position_index: 29, has_moved: true),
          Piece.create(piece_type: 'rook', position: 'a1', color: 'white', position_index: 25)
        ]

        game = Game.create
        game.pieces = game_pieces
        king = game.pieces.find_by(position_index: 29)
        expect(king.castle?('c1', game.pieces)).to be false
      end
    end

    context 'when the king cannot castle because the rook has moved' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game_pieces = [
          Piece.create(piece_type: 'rook', position: 'h8', color: 'black', position_index: 1),
          Piece.create(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.create(piece_type: 'king', position: 'e1', color: 'white', position_index: 29),
          Piece.create(piece_type: 'rook', position: 'a1', color: 'white', position_index: 25, has_moved: true)
        ]

        game = Game.create
        game.pieces = game_pieces
        king = game.pieces.find_by(position_index: 29)
        expect(king.castle?('c1', game.pieces)).to be false
      end
    end
  end

  describe 'pieces_with_next_move' do
    it 'all of the pieces with the next move given' do
      game = Game.create

      piece = game.pieces.find_by(position: 'd2')
      actual = piece.pieces_with_next_move('d4')

      expect(actual.map(&:position).include?('d4')).to be true
    end
  end

  describe 'king_moved_two?' do
    context 'when the piece is not a king' do
      it 'returns false' do
        piece = Piece.new(position: 'e1', piece_type: 'queen')

        expect(piece.king_moved_two?('d4')).to be false
      end
    end

    context 'when the piece is a king and did not move two' do
      it 'returns false' do
        piece = Piece.new(position: 'd2', piece_type: 'king')

        expect(piece.king_moved_two?('d3')).to be false
      end
    end

    context 'when the piece is a king and did move two' do
      it 'returns true' do
        piece = Piece.new(position: 'e1', piece_type: 'king')

        expect(piece.king_moved_two?('c1')).to be true
      end
    end
  end

  describe 'pawn_moved_two?' do
    context 'when the piece is not a pawn' do
      it 'returns false' do
        piece = Piece.new(position: 'd2', piece_type: 'queen')

        expect(piece.pawn_moved_two?('d4')).to be false
      end
    end

    context 'when the piece is a pawn and did not move two' do
      it 'returns false' do
        piece = Piece.new(position: 'd2', piece_type: 'pawn')

        expect(piece.pawn_moved_two?('d3')).to be false
      end
    end

    context 'when the piece is a pawn and did move two' do
      it 'returns true' do
        piece = Piece.new(position: 'd2', piece_type: 'pawn')

        expect(piece.pawn_moved_two?('d4')).to be true
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
end
