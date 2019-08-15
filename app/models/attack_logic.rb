class AttackLogic
  def self.create_signature(game_data, pieces_to_evaluate)
    attackers = game_data.next_attackers(pieces_to_evaluate)
    self.find_signature_value(attackers, game_data.target_pieces, game_data.pieces)
  end

  def self.calculate_attack(current_target_value, attacker_values, defender_values)
    attack_value = 0
    attacker_values.each_with_index do |attacker_value, index|
      if defender_values[index].present?
        attack_value += current_target_value - attacker_value
        current_target_value = defender_values[index]
      else
        attack_value = current_target_value
        break
      end
    end
    attack_value > 0 ? attack_value : 0
  end

  def self.find_signature_value(attackers, target_pieces, pieces)
    signature_value = target_pieces.reduce(0) do |total, piece|
      attacker_values = attackers.select do |attacker|
        attacker.enemy_targets.include?(piece.position_index)
      end.map(&:find_piece_value).sort

      defender_values = Piece.defenders(piece.position_index, pieces)
        .map(&:find_piece_value).sort

      attack_value = calculate_attack(piece.find_piece_value, attacker_values, defender_values)
      if piece.color == 'white'
        total - attack_value
      else
        total + attack_value
      end
    end

    return 1 if signature_value > 1
    return -1 if signature_value < -1
    0
  end
end
