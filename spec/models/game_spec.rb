require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'has many moves' do
    move = Move.new

    game = Game.new
    game.moves << move

    expect(game.moves).to eq [move]
  end

  describe 'move' do
    before do
      allow_any_instance_of(Game).to receive(:ai_turn?).and_return(false)
      allow_any_instance_of(Game).to receive(:in_cache?).and_return(false)
    end

    it 'updates the moved piece\'s position' do
      game = Game.create
      game.move(9, 'a3')

      actual = game.find_piece_by_index(9)
      expect(actual.position).to eq 'a3'
    end

    it 'calls create_notation' do
      expect_any_instance_of(Game).to receive(:update_notation)
        .with(9, 'a3', '')
      game = Game.create(notation: 'abc')
      game.move(9, 'a3')
    end

    it 'calls update_game' do
      game = Game.create
      piece = game.find_piece_by_index(9)
      expect_any_instance_of(Game).to receive(:update_game)
        .with(piece, 'a3', '')

      game.move(9, 'a3')
    end

    context 'when the game has a human player' do
      it 'calls reload_pieces' do
        game = Game.create(game_type: 'human vs human')
        piece = game.find_piece_by_index(9)
        expect_any_instance_of(Game).to receive(:update_game)
          .with(piece, 'a3', '')

        expect_any_instance_of(Game).to receive(:reload_pieces)

        game.move(9, 'a3')
      end
    end
  end

  describe 'join_user_to_game' do
    xit 'test' do
    end
  end

  describe 'ai_turn' do
    context 'when the ai_player is present and the current_turn is the ai_player color' do
      it 'returns true' do
        game = Game.new
        ai_player = AiPlayer.new(color: 'white')
        game.ai_player = ai_player
        expect(game.ai_turn?).to be true
      end
    end

    context 'when the ai_player is not present' do
      it 'returns false' do
        game = Game.new
        expect(game.ai_turn?).to be false
      end
    end

    context 'when the current_turn is not the ai_player\'s turn' do
      it 'returns false' do
        game = Game.new
        ai_player = AiPlayer.new(color: 'black')
        game.ai_player = ai_player
        expect(game.ai_turn?).to be false
      end
    end
  end
end
