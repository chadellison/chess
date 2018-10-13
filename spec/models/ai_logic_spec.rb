require 'rails_helper'

RSpec.describe AiLogic, type: :module do
  before do
    allow_any_instance_of(Game).to receive(:ai_turn?).and_return(false)
  end

  describe 'ai_move' do
    xit 'test' do
    end
  end

  describe 'find_next_moves' do
    it 'returns all the next moves for a color' do
      game = Game.create

      values = [
        '31f3', '31h3', '26a3', '26c3', '24h3', '24h4', '23g3', '23g4', '22f3',
        '22f4', '21e3', '21e4', '20d3', '20d4', '19c3', '19c4', '18b3', '18b4',
        '17a3', '17a4'
      ]

      actual = game.find_next_moves.pluck(:value).all? { |value| values.include?(value) }

      expect(actual).to be true
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

  describe 'promote_to_queen' do
    context 'when there is a crossed pawn' do
      it 'calls crossed_pawn? and returns queen' do
        game = Game.new
        expect(game).to receive(:crossed_pawn?).with('17a8')
          .and_return(true)

        actual = game.promote_to_queen('17a8')
        expect(actual).to eq Queen
      end
    end

    context 'when there is not a crossed pawn' do
      it 'calls crossed_pawn? and returns an empty string' do
        game = Game.new
        expect(game).to receive(:crossed_pawn?).with('17a7')
          .and_return(false)

        actual = game.promote_to_queen('17a7')
        expect(actual).to be_nil
      end
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
