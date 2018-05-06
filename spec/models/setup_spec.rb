require 'rails_helper'

RSpec.describe Setup, type: :model do
  it 'has many game_setups' do
    setup = Setup.new
    game_setup = GameSetup.new
    setup.game_setups << game_setup

    expect(setup.game_setups).to eq [game_setup]
  end

  it 'has many games' do
    game = Game.new

    setup = Setup.new
    setup.games << game

    expect(setup.games).to eq [game]
  end
end
