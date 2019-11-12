class AttackLogic
  def self.attack_pattern(game_data)
    (calculate_attack(game_data.target_pieces, game_data.opponent_color)).round(1)
  end

  def self.threat_pattern(game_data)
    (1.0 - calculate_attack(game_data.target_pieces, game_data.turn)).round(1)
  end

  def self.calculate_attack(pieces, turn)
    attack_value = 0
    total_target_value = 0

    pieces.each do |target_piece|
      piece_value = target_piece.find_piece_value
      attack_value += piece_value if target_piece.color == turn

      total_target_value += piece_value
    end

    return 0 if total_target_value == 0
    attack_value.to_f / total_target_value.to_f
  end

  def self.threatened_attacker_pattern(game_data)
    threatened_attacker_value = game_data.ally_attackers.reduce(0) do |total, ally_attacker|
      if game_data.targets.include?(ally_attacker.position_index)
        total += ally_attacker.find_piece_value
      end
      total
    end

    total_attack_value = game_data.target_pieces.reduce(0) do |total, target|
      total + target.find_piece_value
    end

    return 0 if total_attack_value == 0

    (1.0 - (threatened_attacker_value.to_f / total_attack_value.to_f)).round(1)
  end
end
