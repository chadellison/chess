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
    it 'updates the moved piece\'s position' do
      game = Game.create
      game.move(9, 'a3')

      actual = game.pieces.find_by(position_index: 9).position
      expect(actual).to eq 'a3'
    end

    it 'calls update_board' do
      expect_any_instance_of(Game).to receive(:update_board)
      game = Game.create
      game.move(9, 'a3')
    end
  end

  describe 'update_board' do
    it 'creates a move position_signature of the current board positions' do
      game = Game.create
      game.update_board

      expected = "1a82b83c84d85e86f87g88h89a310b711c712d713e714f715g716h717a218b219c220d221e222f223g224h225a126b127c128d129e130f131g132h1"

      actual = game.setups.first.position_signature
      expect(actual[0..10]).to eq expected[0..10]
    end

    it 'creates a setup on the game if it does not already exist' do
      game = Game.create

      expect { game.update_board }.to change { game.setups.count }.by(1)
    end
  end

  describe 'after_commits' do
    describe '#add_pieces' do
      it 'adds 32 pieces to a game' do
        expect { Game.create }.to change { Piece.count }.by(32)
      end
    end
  end
end
