require 'rails_helper'

RSpec.describe DefenseLogic, type: :model do
  let(:pieces) { [Piece.new] }
  let(:ally_targets) { [Piece.new] }
  let(:opponent_targets) { [Piece.new] }
  let(:game_data) { GameData.new(Move.new, pieces, 'white', 0) }
  describe 'ally_defense_pattern' do
    it 'calls calculate_defense with the correct arguments' do
      allow_any_instance_of(GameData).to receive(:pieces)
        .and_return(pieces)

      allow_any_instance_of(GameData).to receive(:ally_targets)
        .and_return(ally_targets)

      expect(DefenseLogic).to receive(:calculate_defense)
        .with(pieces, ally_targets)
        .and_return(0.4)

      actual = DefenseLogic.ally_defense_pattern(game_data)

      expect(actual).to eq 0.4
    end
  end

  describe 'opponent_defense_pattern' do
    it 'calls calculate_defense with the correct arguments' do
      allow_any_instance_of(GameData).to receive(:pieces)
        .and_return(pieces)

      allow_any_instance_of(GameData).to receive(:opponent_targets)
        .and_return(opponent_targets)

      expect(DefenseLogic).to receive(:calculate_defense)
        .with(pieces, opponent_targets)
        .and_return(0.4)

      actual = DefenseLogic.opponent_defense_pattern(game_data)

      expect(actual).to eq 0.6
    end
  end

  describe 'calculate_defense' do
    describe 'when an undefended queen is being attacked' do
      it 'returns 0' do
        all_pieces = [Piece.new(piece_type: 'pawn'), Piece.new(piece_type: 'knight')]
        all_targets = [Piece.new(piece_type: 'bishop')]

        allow(DefenseLogic).to receive(:target_defense_value)
          .and_return(0)

        actual = DefenseLogic.calculate_defense(all_pieces, all_targets)

        expect(actual).to eq 0
      end
    end

    describe 'when a defended queen is being attacked by rook' do
      it 'returns 0' do
        pawn = Piece.new(piece_type: 'pawn')
        rook = Piece.new(piece_type: 'rook')
        queen = Piece.new(piece_type: 'queen', position_index: 4)

        all_pieces = [rook, pawn]
        all_targets = [queen]

        allow(Piece).to receive(:defenders).and_return([pawn])

        allow(rook).to receive(:enemy_targets).and_return([4])

        actual = DefenseLogic.calculate_defense(all_pieces, all_targets)

        expect(actual).to eq 0
      end
    end

    describe 'when a defended bishop is attacked by a rook' do
      it 'returns 2' do
        pawn = Piece.new(piece_type: 'pawn')
        rook = Piece.new(piece_type: 'rook')
        bishop = Piece.new(piece_type: 'bishop', position_index: 3)

        all_pieces = [rook, pawn, bishop]
        all_targets = [bishop]

        allow(Piece).to receive(:defenders).and_return([pawn])

        allow(rook).to receive(:enemy_targets).and_return([3])

        actual = DefenseLogic.calculate_defense(all_pieces, all_targets)

        expect(actual).to eq 0.7
      end
    end
  end
end
