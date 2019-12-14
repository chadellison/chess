class DefenseLogic
  def self.ally_defense_pattern(game_data)
    return 1.0 if game_data.ally_targets.blank?
    focused_defense_value = defense_value(
      game_data.pieces,
      game_data.ally_targets
    )
    return 0.0 if focused_defense_value < 0
    return 0.5 if focused_defense_value == 0
    1.0
  end

  def self.opponent_defense_pattern(game_data)
    target_ids = game_data.non_targeted_ally_attackers
                          .map(&:enemy_targets)
                          .flatten
                          .uniq

    targets = game_data.opponent_targets.select do |opponent|
      target_ids.include?(opponent.position_index)
    end

    return 0.0 if targets.blank?

    focused_defense_value = defense_value(
      game_data.pieces,
      targets
    )
    return 1.0 if focused_defense_value < 0
    return 0.5 if focused_defense_value == 0
    0.0
  end

  def self.defense_value(all_pieces, targets)
    targets.map do |target|
      target_defense_value(all_pieces, target)
    end.min
  end

  def self.target_defense_value(all_pieces, target_piece)
    attackers = attacker_values_of_piece(all_pieces, target_piece)
    defenders = target_piece.defenders.map(&:find_piece_value).sort

    defense_value = 0 - target_piece.find_piece_value
    defenders.each_with_index do |defender, index|
      defense_value += attackers[index].to_i
      defense_value -= defender if attackers[index + 1].present?
    end
    defense_value
  end

  def self.attacker_values_of_piece(pieces, target_piece)
    pieces.select do |piece|
      piece.enemy_targets.include?(target_piece.position_index)
    end.map(&:find_piece_value).sort
  end
end
