require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'pieces' do
    context 'when the pieces attribute is nil' do
      it 'returns 32 pieces' do
        game = Game.new

        expect(game.pieces.count).to eq 32
      end
    end
  end

  it 'has many moves' do
    move = Move.new

    game = Game.new
    game.moves << move

    expect(game.moves).to eq [move]
  end

  describe 'move' do
    before do
      allow_any_instance_of(Game).to receive(:ai_turn?).and_return(false)
    end

    it 'updates the moved piece\'s position and has_moved property' do
      game = Game.create
      game.move(9, 'a3')

      actual = game.find_piece_by_index(9)
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
      piece = game.find_piece_by_index(9)
      expect_any_instance_of(Game).to receive(:update_piece)
        .with(piece, 'a3', '')
      game.move(9, 'a3')
    end
  end

  describe 'after_commits' do
    describe 'add_pieces' do
      it 'adds 32 pieces to a game' do
        game = Game.create
        expect(game.pieces.count).to eq 32
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
