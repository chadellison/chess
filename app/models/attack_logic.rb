class AttackLogic
  def self.attack_pattern(game_data)
    opponent_target_ids = game_data.non_targeted_ally_attackers
                                   .map(&:enemy_targets)
                                   .flatten
                                   .uniq

    calculate_attack(opponent_target_ids, game_data.duplicated_targets).round(1)
  end

  def self.threat_pattern(game_data)
    ally_target_ids = game_data.opponent_attackers.map(&:enemy_targets).flatten
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
        target_defenders = ally_attacker.defenders.select do |defender|
                             !game_data.ally_attackers
                                       .map(&:position_index)
                                       .include?(defender.position_index) &&
                                         game_data.targets.include?(defender.position_index)
                           end

        total += (target_defenders.map(&:find_piece_value).sum * -1)
        total += DefenseLogic.target_defense_value(game_data.pieces, ally_attacker)
      end
      total
    end

    return 0.0 if threatened_attacker_value < 0
    threatened_attacker_value.to_f
  end
end
