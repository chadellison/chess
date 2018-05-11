require 'rails_helper'

RSpec.describe Move, type: :model do
  it 'belongs to a game' do
    move = Move.new
    game = Game.new
    game.moves << move

    expect(move.game).to eq game
  end

  it 'belongs to a setup' do
    move = Move.new
    setup = Setup.new
    move.setup = setup

    expect(move.setup).to eq setup
  end
end
