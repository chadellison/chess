class DefenseLogic
  def self.ally_defense_pattern(game_data)
    (calculate_defense(game_data.pieces, game_data.ally_targets)).round(1)
  end

  def self.opponent_defense_pattern(game_data)
    (1.0 - calculate_defense(game_data.pieces, game_data.opponent_targets)).round(1)
  end

  def self.calculate_defense(all_pieces, targets)
    total_defense_value = targets.reduce(0) do |total, target|
      total + target_defense_value(all_pieces, target)
    end

    total_target_value = targets.reduce(0) do |total, target|
      target.find_piece_value
    end

    return 0 if total_defense_value <= 0

    (total_defense_value.to_f / total_target_value.to_f).round(1)
  end

  def self.target_defense_value(all_pieces, target_piece)
    attackers = attacker_values_of_piece(all_pieces, target_piece)
    defenders = defender_values_of_piece(all_pieces, target_piece)

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

  def self.defender_values_of_piece(pieces, target_piece)
    pieces.select do |piece|
      Piece.defenders(pieces, target_piece.position_index)
    end.map(&:find_piece_value).sort
  end
end
