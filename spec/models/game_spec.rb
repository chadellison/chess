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

  it 'has many moves' do
    move = Move.new

    game = Game.new
    game.moves << move

    expect(game.moves).to eq [move]
  end

  describe 'current_setup' do
    xit 'test' do
    end
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

    it 'calls update_piece' do
      game = Game.create
      piece = game.pieces.find_by(position_index: 9)
      expect_any_instance_of(Game).to receive(:update_piece)
        .with(piece, 'a3', '')
      game.move(9, 'a3')
    end
  end

  describe 'after_commits' do
    describe 'add_pieces' do
      it 'adds 32 pieces to a game' do
        expect { Game.create }.to change { Piece.count }.by(32)
      end
    end
  end    
end
