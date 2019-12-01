class DefenseLogic
  # def self.general_defense_pattern(game_data)
    # numerator = 0.0
    # denominator = 0.0
    # game_data.pieces.each do |piece|
    #   defender_size = game_data.defender_index[piece.position_index].size
    #   numerator += defender_size if piece.color == game_data.turn
    #   denominator += defender_size
    # end
    #
    # (numerator / denominator).round(1)
  #   0.0
  # end

  def self.ally_defense_pattern(game_data)
    return 1.0 if game_data.ally_targets.blank?
    focused_defense_value = defense_value(
      game_data.pieces,
      game_data.ally_targets,
      game_data.defender_index
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
      targets,
      game_data.defender_index
    )
    return 1.0 if focused_defense_value < 0
    return 0.5 if focused_defense_value == 0
    0.0
  end

  def self.defense_value(all_pieces, targets, defender_index)
    targets.map do |target|
      target_defense_value(all_pieces, target, defender_index)
    end.min
  end

  def self.target_defense_value(all_pieces, target_piece, defender_index)
    attackers = attacker_values_of_piece(all_pieces, target_piece)
    defenders = defender_index[target_piece.position_index].map(&:find_piece_value).sort

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
