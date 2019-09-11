require 'rails_helper'

RSpec.describe AttackLogic, type: :model do
  let(:game_data) {
    GameData.new(Move.new, [Piece.new], 'white', 3)
  }

  let(:target_pieces) {
    [Piece.new, Piece.new]
  }
  describe 'attack_pattern' do
    it 'calls calculate_attack with the correct arguments' do
      allow_any_instance_of(GameData).to receive(:target_pieces)
        .and_return(target_pieces)

      allow_any_instance_of(GameData).to receive(:opponent_color)
        .and_return('black')

      expect(AttackLogic).to receive(:calculate_attack)
        .with(target_pieces, 'black')
        .and_return(0.45)

      actual = AttackLogic.attack_pattern(game_data)

      expect(actual).to eq 0.5
    end
  end

  describe 'threat_pattern' do
    it 'calls calculate_attack with the correct arguments' do
      allow_any_instance_of(GameData).to receive(:target_pieces)
        .and_return(target_pieces)

      allow_any_instance_of(GameData).to receive(:opponent_color)
        .and_return('white')

      expect(AttackLogic).to receive(:calculate_attack)
        .with(target_pieces, 'white').and_return(0.723)

      actual = AttackLogic.threat_pattern(game_data)

      expect(actual).to eq(0.3)
    end
  end

  describe 'calculate_attack' do
    describe 'when the total target value is 0' do
      it 'returns 0' do
        expect(AttackLogic.calculate_attack([], 'white')).to eq 0
      end
    end

    describe 'when the total target value is not 0' do
      it 'returns the attack value over the total value' do
        target_pieces = [
          Piece.new(piece_type: 'queen', color: 'white'),
          Piece.new(piece_type: 'bishop', color: 'black')
        ]

        actual = AttackLogic.calculate_attack(target_pieces, 'white')
        expect(actual).to eq 0.75
      end
    end
  end

  describe 'threatened_attacker_pattern' do
    describe 'when the total attack_value is 0' do
      it 'returns 0' do
        allow_any_instance_of(GameData).to receive(:ally_attackers)
          .and_return([Piece.new])

        allow_any_instance_of(GameData).to receive(:target_pieces)
          .and_return([])

        expect(AttackLogic.threatened_attacker_pattern(game_data)).to eq 0
      end
    end

    describe 'when the total attack_value is not 0' do
      it 'returns the threatened_attacker value over the total oppoenent target value' do
        ally = Piece.new(position_index: 1, piece_type: 'queen')
        oppoenent = Piece.new(position_index: 2, piece_type: 'rook')
        pieces = [ally, oppoenent]

        allow_any_instance_of(GameData).to receive(:ally_attackers)
          .and_return([ally])

        allow_any_instance_of(GameData).to receive(:targets)
          .and_return(pieces)

        allow_any_instance_of(GameData).to receive(:target_pieces)
          .and_return(pieces)

        allow_any_instance_of(GameData).to receive(:targets)
          .and_return([1, 2])
        expect(AttackLogic.threatened_attacker_pattern(game_data)).to eq 0.4
      end
    end
  end
end
