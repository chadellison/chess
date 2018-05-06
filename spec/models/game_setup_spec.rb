require 'rails_helper'

RSpec.describe GameSetup, type: :model do
  it 'belongs to a game' do
    game_setup = GameSetup.new
    game = Game.new
    game.game_setups << game_setup

    expect(game_setup.game).to eq game
  end

  it 'belongs to a setup' do
    game_setup = GameSetup.new
    setup = Setup.new
    setup.game_setups << game_setup

    expect(game_setup.setup).to eq setup
  end
end
