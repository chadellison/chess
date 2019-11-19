class AttackLogic
  def self.attack_pattern(game_data)
    opponent_target_ids = game_data.non_targeted_ally_attackers
                                   .map(&:enemy_targets)
                                   .flatten

    calculate_attack(opponent_target_ids, game_data.duplicated_targets).round(1)
  end

  def self.threat_pattern(game_data)
    ally_target_ids = game_data.opponent_attackers.map(&:enemy_targets)
    (1.0 - calculate_attack(ally_target_ids, game_data.duplicated_targets)).round(1)
  end

  def self.calculate_attack(target_ids, all_targets)
    attack_value = 0
    total_target_value = 0

    all_targets.each do |target_piece|
      piece_value = target_piece.find_piece_value
      attack_value += piece_value if target_ids.include?(target_piece.position_index)

      total_target_value += piece_value
    end

    return 0 if total_target_value == 0
    attack_value.to_f / total_target_value.to_f
  end

  def self.threatened_attacker_pattern(game_data)
    threatened_attacker_value = game_data.ally_attackers.reduce(0) do |total, ally_attacker|
      if game_data.targets.include?(ally_attacker.position_index)
        defense_value = DefenseLogic.target_defense_value(game_data.pieces, ally_attacker, game_data.defender_index)
        total += (defense_value * -1)
      end
      total
    end

    enemy_target_value = game_data.target_pieces.reduce(0) do |total, target|
      total + target.find_piece_value
    end.to_f

    return 0 if enemy_target_value == 0
    return 1 if threatened_attacker_value <= 0
    (1.0 - (threatened_attacker_value.to_f / enemy_target_value.to_f)).round(1)
  end
end
