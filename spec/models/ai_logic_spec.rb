require 'rails_helper'

RSpec.describe AiLogic, type: :module do
  before do
    allow_any_instance_of(Game).to receive(:ai_turn?).and_return(false)
  end

  describe 'ai_move' do
    xit 'test' do
    end
  end

  describe 'all_next_moves_for_piece' do
    xit 'test' do
    end
  end

  describe 'setup_analysis' do
    xit 'test' do
    end
  end

  describe 'best_rank_setup' do
    it 'test' do
    end
  end

  describe 'winning_setups' do
    xit 'test' do
    end
  end

  describe 'piece_analysis' do
    xit 'test' do
    end
  end

  describe 'current_turn' do
    context 'when there are an even number of moves on a game' do
      it 'returns white' do
        game = Game.new

        expect(game.current_turn).to eq 'white'
      end
    end

    context 'when there are an odd number of moves on a game' do
      it 'returns black' do
        game = Game.create
        move = game.moves.create

          expect(game.current_turn).to eq 'black'
      end
    end
  end

  describe 'opponent_color' do
    context 'when it is white\'s turn' do
      it 'returns black' do
        allow_any_instance_of(Game).to receive(:current_turn).and_return('white')
        game = Game.new

        expect(game.opponent_color).to eq 'black'
      end
    end

    context 'when it is black\'s turn' do
      it 'returns white' do
        allow_any_instance_of(Game).to receive(:current_turn).and_return('black')
        game = Game.new

        expect(game.opponent_color).to eq 'white'
      end
    end
  end

  describe 'find_checkmate' do
    xit 'test' do
    end
  end

  describe 'position_index_from_move' do
    xit 'test' do
    end
  end

  describe 'crossed_pawn?' do
    xit 'test' do
    end
  end

  describe 'wins_from_notation' do
    xit 'test' do
    end
  end

  describe 'random_winning_game' do
    xit 'test' do
    end
  end

  describe 'best_move_from_notation' do
    xit 'test' do
    end
  end

  describe 'start_index' do
    xit 'test' do
    end
  end

  describe 'position_analysis' do
    xit 'test' do
    end
  end
end
