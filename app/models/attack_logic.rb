class AttackLogic
  INITIAL_VALUE = 0.01

  VALUE_BY_INDEX = {
    1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 0, 6 => 3, 7 => 3, 8 => 5, 9 => 1,
    10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => 1,
    18 => 1, 19 => 1, 20 => 1, 21 => 1, 22 => 1, 23 => 1, 24 => 1, 25 => 5,
    26 => 3, 27 => 3, 28 => 9, 29 => 0, 30 => 3, 31 => 3, 32 => 5
  }

  def self.create_signature(new_pieces)
    attackers = new_pieces.select { |piece| piece.enemy_targets.present? }
    white_attackers = attackers.select { |attacker| attacker.color == 'white' }
    black_attackers = attackers.select { |attacker| attacker.color == 'black' }

    white_attack_ratio = attack_ratio(white_attackers, new_pieces)
    black_attack_ratio = attack_ratio(black_attackers, new_pieces)

    (white_attack_ratio / black_attack_ratio).round(3).to_s
  end

  def self.attack_ratio(attackers, new_pieces)
    target_value = INITIAL_VALUE
    defense_value = INITIAL_VALUE

    attackers.each do |attacker|
      attacker.enemy_targets.each do |target|
        target_value += VALUE_BY_INDEX[target]
        defense_value += Piece.defenders(target, new_pieces).size * attacker.find_piece_value
      end
    end

    target_value / defense_value
  end
end
