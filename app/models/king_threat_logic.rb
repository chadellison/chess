class KingThreatLogic
  def self.check_pattern(game_data)
    can_threaten = game_data.ally_attackers.any? do |ally|
      (ally.enemy_targets.include?(5) || ally.enemy_targets.include?(29)) &&
        !game_data.targets.include?(ally.position_index)
    end
    can_threaten ? 1.0 : 0.0
  end
end
