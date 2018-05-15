require 'rails_helper'

RSpec.describe AiLogic, type: :module do
  describe 'ai_move' do
    xit 'test' do
    end
  end

  describe 'find_next_moves' do
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

  describe 'handle_ratio' do
    it 'calls double_position_match and single_position_match' do
      expect_any_instance_of(Game).to receive(:double_position_match)\
        .with('1a4', '2b4')
        .and_return([])
      expect_any_instance_of(Game).to receive(:single_position_match)
        .with('1a4')
        .and_return([])

      game = Game.new

      game.handle_ratio('1a4', '2b4')
    end

    context 'when the match amount is 0' do
      it 'returns 0' do
        allow_any_instance_of(Game).to receive(:double_position_match)\
        .with('1a4', '2b4')
        .and_return([])
        allow_any_instance_of(Game).to receive(:single_position_match)
        .with('1a4')
        .and_return([Setup.new])

        game = Game.new

        expect(game.handle_ratio('1a4', '2b4')).to eq 0
      end
    end

    context 'when the total is 0' do
      it 'returns 0' do
        allow_any_instance_of(Game).to receive(:double_position_match)\
          .with('1a4', '2b4')
          .and_return([Setup.new])
        allow_any_instance_of(Game).to receive(:single_position_match)
          .with('1a4')
          .and_return([])

        game = Game.new

        expect(game.handle_ratio('1a4', '2b4')).to eq 0
      end
    end

    context 'when neither the match nor the total is 0' do
      it 'returns the ratio' do
        allow_any_instance_of(Game).to receive(:double_position_match)\
          .with('1a4', '2b4')
          .and_return([Setup.new])
        allow_any_instance_of(Game).to receive(:single_position_match)
          .with('1a4')
          .and_return([Setup.new, Setup.new])

        game = Game.new

        expect(game.handle_ratio('1a4', '2b4')).to eq 0.5
      end
    end
  end

  describe 'single_position_match' do
    xit 'test' do
    end
  end

  describe 'double_position_match' do
    xit 'test' do
    end
  end

  describe 'current_turn' do
    xit 'test' do
    end
  end

  describe 'opponent_color' do
    xit 'test' do
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

  describe 'promote_pawn' do
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

  describe 'material_analysis' do
    context 'when a pawn is captured' do
      it 'returns the material difference between the current state and the next move' do
        game = Game.create

        game.pieces.find_by(position_index: 20).update(position: 'd4')
        game.pieces.find_by(position_index: 11).update(position: 'c5')

        expect(game.material_analysis('20c5')).to eq 1
        expect(game.material_analysis('20d5')).to eq 0
      end
    end

    context 'when a queen is captured' do
      it 'returns the material difference between the current state and the next move' do
        game = Game.create

        game.pieces.find_by(position_index: 20).destroy
        game.move(28, 'd4')
        game.pieces.find_by(position_index: 11).update(position: 'c5')

        expect(game.material_analysis('11d4')).to eq 9
      end
    end
  end

  describe 'find_material_value' do
    it 'returns the sum of a color\'s material value' do
      game = Game.new

      pieces = [
        Piece.new(piece_type: 'queen', color: 'white'),
        Piece.new(piece_type: 'pawn', color: 'white'),
        Piece.new(piece_type: 'rook', color: 'black'),
        Piece.new(piece_type: 'bishop', color: 'black')
      ]

      expect(game.find_material_value(pieces, 'white')).to eq 10
      expect(game.find_material_value(pieces, 'black')).to eq 8
    end
  end
end
