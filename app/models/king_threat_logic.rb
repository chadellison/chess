class KingThreatLogic
  def self.check_pattern(game_data)
    can_threaten = game_data.ally_attackers.any? do |ally|
      (ally.enemy_targets.include?(5) || ally.enemy_targets.include?(29)) &&
        !game_data.targets.include?(ally.position_index)
    end
    can_threaten ? 1.0 : 0.0
  end

  def self.threat_pattern(game_data)
    opponent_king = game_data.kings.detect do |king|
      king.color == game_data.opponent_color
    end

    spaces_near_king = opponent_king.spaces_near_king

    threat_value = 0
    game_data.allies.each do |ally|
      if !game_data.targets.include?(ally.position_index) ||
          DefenseLogic.target_defense_value(game_data.pieces, ally) > 0
              threat_value += (spaces_near_king & ally.valid_moves).size
      end
    end

    threat_value.to_f
  end

  def self.threat_preparation_pattern(game_data)
    opponent_king = game_data.kings.detect do |king|
      king.color == game_data.opponent_color
    end

    spaces_near_king = opponent_king.spaces_near_king

    threat_value = 0
    game_data.allies.each do |ally|
      if !game_data.targets.include?(ally.position_index) ||
          DefenseLogic.target_defense_value(game_data.pieces, ally) > 0
              threat_value += (spaces_near_king & ally.moves_for_piece).size
      end
    end

    threat_value.to_f
  end
end
