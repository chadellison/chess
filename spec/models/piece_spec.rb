require 'rails_helper'

RSpec.describe Piece, type: :model do
  describe 'game' do
    it 'finds the game associated with the game_id' do
      piece = Piece.new(game_id: 1)
      expect(Game).to receive(:find).with(1)
      piece.game
    end
  end

  describe 'moves_for_piece' do
    context 'when the piece_type is a pawn' do
      it 'calls moves_for_pawn' do
        piece = Piece.new(piece_type: 'pawn')

        expect_any_instance_of(Piece).to receive(:moves_for_pawn)

        piece.moves_for_piece
      end
    end

    context 'when the piece_type is a knight' do
      it 'calls moves_for_knight' do
        piece = Piece.new(piece_type: 'knight')

        expect_any_instance_of(Piece).to receive(:moves_for_knight)

        piece.moves_for_piece
      end
    end

    context 'when the piece_type is a bishop' do
      it 'calls moves_for_bishop' do
        piece = Piece.new(piece_type: 'bishop')

        expect_any_instance_of(Piece).to receive(:moves_for_bishop)

        piece.moves_for_piece
      end
    end

    context 'when the piece_type is a rook' do
      it 'calls moves_for_rook' do
        piece = Piece.new(piece_type: 'rook')

        expect_any_instance_of(Piece).to receive(:moves_for_rook)

        piece.moves_for_piece
      end
    end

    context 'when the piece_type is a queen' do
      it 'calls moves_for_queen' do
        piece = Piece.new(piece_type: 'queen')

        expect_any_instance_of(Piece).to receive(:moves_for_queen)

        piece.moves_for_piece
      end
    end

    context 'when the piece_type is a king' do
      it 'calls moves_for_king' do
        piece = Piece.new(piece_type: 'king')

        expect_any_instance_of(Piece).to receive(:moves_for_king)

        piece.moves_for_piece
      end
    end
  end

  describe 'valid_moves' do
    context 'when the king is in check' do
      it 'returns all moves to get the king out of check' do

        game_pieces = [
          Piece.new(piece_type: 'king', color: 'black', position_index: 5, position: 'e8'),
          Piece.new(piece_type: 'king', color: 'white', position_index: 29, position: 'e1'),
          Piece.new(piece_type: 'queen', color: 'white', position_index: 28, position: 'e2'),
        ]
        allow_any_instance_of(Game).to receive(:add_pieces).and_return(game_pieces)

        game = Game.create

        game.pieces.each { |piece| piece.game_id = game.id }

        piece = game.find_piece_by_index(5)
        expected = ['d8', 'f8', 'd7', 'f7']

        expect(piece.valid_moves(game.pieces)).to eq expected
      end
    end

    context 'when the king must kill a piece to get out of check' do
      it 'returns all moves to get the king out of check' do
        allow_any_instance_of(Game).to receive(:add_pieces).and_return([])
        game = Game.create

        piece1 = Piece.new(
          piece_type: 'king',
          color: 'black',
          position_index: 5,
          position: 'e8',
          game_id: game.id
        )
        piece2 = Piece.new(
          piece_type: 'king',
          color: 'white',
          position_index: 29,
          position: 'e1',
          game_id: game.id
        )

        piece3 = Piece.new(
          piece_type: 'queen',
          color: 'white',
          position_index: 28,
          position: 'e7',
          game_id: game.id
        )

        game.pieces << piece1
        game.pieces << piece2
        game.pieces << piece3

        expected = ['e7']

        expect(piece1.valid_moves(game.pieces)).to eq expected
      end
    end

    context 'when the king is in checkmate' do
      it 'returns an empty array' do
        game = Game.create

        piece1 = Piece.new(
          piece_type: 'king',
          color: 'black',
          position_index: 5,
          position: 'e8',
          game_id: game.id
        )
        piece2 = Piece.new(
          piece_type: 'king',
          color: 'white',
          position_index: 29,
          position: 'e1',
          game_id: game.id
        )

        piece3 = Piece.new(
          piece_type: 'queen',
          color: 'white',
          position_index: 28,
          position: 'e7',
          game_id: game.id
        )

        piece4 = Piece.new(
          piece_type: 'knight',
          color: 'white',
          position_index: 26,
          position: 'd5',
          game_id: game.id
        )

        game.pieces << piece1
        game.pieces << piece2
        game.pieces << piece3
        game.pieces << piece4

        expected = []

        expect(piece1.valid_moves(game.pieces)).to eq expected
      end
    end

    context 'when there are pieces blocking all of a piece\'s moves' do
      it 'returns an empty array' do
        game = Game.create

        piece = game.find_piece_by_position('d1')

        expect(piece.valid_moves(game.pieces)).to eq []
      end
    end

    context 'when there are pieces blocking all of a piece\'s moves except one' do
      it 'returns one position' do
        game = Game.create
        game.move(20, 'd3')
        piece = game.find_piece_by_position('d1')

        expect(piece.valid_moves(game.pieces)).to eq ['d2']
      end
    end
  end

  describe '#valid_for_piece' do
    context 'when a king can castle' do
      let(:game) { Game.create }
      before do
        game.pieces.reject! { |piece| ['f1', 'g1'].include?(piece.position) }
      end

      it 'returns true when the next move is a castle' do
        piece = game.find_piece_by_index(29)
        expect(piece.valid_for_piece?('g1', game.pieces)).to be true
      end
    end

    context 'when a king cannot castle due to having moved' do
      let(:game) { Game.create }

      before do
        game.pieces.reject! { |piece| ['f1', 'g1'].include?(piece.position) }
      end

      it 'returns false when the next move is a castle' do
        piece = game.find_piece_by_index(29)
        piece.has_moved = true

        expect(piece.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to it\'s rook moving' do
      let(:game) { Game.create }

      before do
        game.pieces.reject! { |piece| ['f1', 'g1'].include?(piece.position) }
      end

      it 'returns false when the next move is a castle' do
        rook = game.find_piece_by_index(32)
        rook.has_moved = true

        king = game.find_piece_by_index(29)

        expect(king.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to it\'s rook not being present' do
      let(:game) { Game.create }

      before do
        game.pieces.reject! { |piece| ['f1', 'g1', 'h1'].include?(piece.position) }
      end

      it 'returns false when the next move is a castle' do
        king = game.find_piece_by_index(29)

        expect(king.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to being in check' do
      it 'returns false' do
        game_pieces = [
          Piece.new(piece_type: 'queen', position: 'e7', color: 'black', position_index: 4),
          Piece.new(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.new(piece_type: 'king', position: 'e1', color: 'white', position_index: 29),
          Piece.new(piece_type: 'rook', position: 'a8', color: 'white', position_index: 25)
        ]

        allow_any_instance_of(Game).to receive(:add_pieces)
          .and_return(game_pieces)

        game = Game.create

        game.pieces.each { |piece| piece.game_id = game.id }

        king = game.find_piece_by_index(29)

        expect(king.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to moving through check' do
      it 'returns false when the next move is a castle' do
        game_pieces = [
          Piece.new(piece_type: 'rook', position: 'd8', color: 'black'),
          Piece.new(piece_type: 'king', position: 'e8', color: 'black'),
          Piece.new(piece_type: 'king', position: 'e1', color: 'white'),
          Piece.new(piece_type: 'rook', position: 'a8', color: 'white')
        ]

        allow_any_instance_of(Game).to receive(:add_pieces)
          .and_return(game_pieces)

        game = Game.create

        game.pieces.each { |piece| piece.game_id = game.id }
        king = game.pieces.detect { |piece| piece.piece_type == 'king' }
        expect(king.valid_for_piece?('c1', game.pieces)).to be false
      end
    end
  end

  describe 'can_castle?' do
    context 'when the king can castle' do
      it 'returns true' do
        game_pieces = [
          Piece.new(piece_type: 'rook', position: 'h8', color: 'black', position_index: 1),
          Piece.new(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.new(piece_type: 'king', position: 'e1', color: 'white', position_index: 29),
          Piece.new(piece_type: 'rook', position: 'a1', color: 'white', position_index: 25)
        ]

        allow_any_instance_of(Game).to receive(:add_pieces).and_return(game_pieces)

        game = Game.create
        game.pieces.each { |piece| piece.game_id = game.id }
        king = game.find_piece_by_index(29)
        expect(king.can_castle?('c1', game.pieces)).to be true
      end
    end

    context 'when the king cannot castle because the rook is not on the same row' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:add_pieces).and_return([])
        game = Game.create

        piece1 = Piece.new(piece_type: 'rook', position: 'd8', color: 'black', game_id: game.id)
        piece2 = Piece.new(piece_type: 'king', position: 'e1', color: 'white', game_id: game.id)
        piece3 = Piece.new(piece_type: 'rook', position: 'a8', color: 'white', game_id: game.id)

        game.pieces << piece1
        game.pieces << piece2
        game.pieces << piece3
        king = game.pieces.detect { |piece| piece.piece_type == 'king' }
        expect(king.can_castle?('c1', game.pieces)).to be false
      end
    end

    context 'when the king cannot castle because the king has moved' do
      it 'returns true' do
        game_pieces = [
          Piece.new(piece_type: 'rook', position: 'h8', color: 'black', position_index: 1),
          Piece.new(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.new(piece_type: 'king', position: 'e1', color: 'white', position_index: 29, has_moved: true),
          Piece.new(piece_type: 'rook', position: 'a1', color: 'white', position_index: 25)
        ]

        allow_any_instance_of(Game).to receive(:add_pieces).and_return(game_pieces)

        game = Game.create
        game.pieces.each { |piece| piece.game_id = game.id }
        king = game.find_piece_by_index(29)
        expect(king.can_castle?('c1', game.pieces)).to be false
      end
    end

    context 'when the king cannot castle because the rook has moved' do
      it 'returns true' do
        game_pieces = [
          Piece.new(piece_type: 'rook', position: 'h8', color: 'black', position_index: 1),
          Piece.new(piece_type: 'king', position: 'e8', color: 'black', position_index: 5),
          Piece.new(piece_type: 'king', position: 'e1', color: 'white', position_index: 29),
          Piece.new(piece_type: 'rook', position: 'a1', color: 'white', position_index: 25, has_moved: true)
        ]

        allow_any_instance_of(Game).to receive(:add_pieces).and_return(game_pieces)

        game = Game.create
        game.pieces.each { |piece| piece.game_id = game.id }
        king = game.find_piece_by_index(29)
        expect(king.can_castle?('c1', game.pieces)).to be false
      end
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

  describe '#valid_move?' do
    let(:game) { Game.create }

    let(:piece) {
      Piece.new(
        piece_type: 'king',
        color: 'black',
        position_index: 13,
        position: 'e7',
        game_id: game.id
      )
    }

    it 'calls valid_move_path?' do
      allow_any_instance_of(Game).to receive(:add_pieces)
        .and_return([])

      game.pieces << piece
      expect_any_instance_of(Piece).to receive(:valid_move_path?)
        .with('e5', piece.game.pieces.map(&:position))
      piece.valid_move?(game.pieces, 'e5')
    end

    it 'calls valid_destination?' do
      expect_any_instance_of(Piece).to receive(:valid_destination?)
        .with('e5', game.pieces)

      piece.valid_move?(game.pieces, 'e5')
    end

    it 'calls valid_for_piece?' do
      expect_any_instance_of(Piece).to receive(:valid_for_piece?)
        .with('e5', game.pieces)

      piece.valid_move?(game.pieces, 'e5')
    end

    it 'calls king_is_safe?' do
      expect_any_instance_of(Piece).to receive(:king_is_safe?)
      expect_any_instance_of(Game).to receive(:pieces_with_next_move)
        .with(game.pieces, '13e5')

      piece.valid_move?(game.pieces, 'e5')
    end
  end
end
