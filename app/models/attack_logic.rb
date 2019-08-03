class AttackLogic
  def self.create_signature(game_data)
    pieces = game_data.pieces
    targets = game_data.targets
    turn = game_data.turn

    attackers = pieces.select { |piece| piece.enemy_targets.present? }.select do |piece|
      [
        piece.color != turn,
        !targets.include?(piece.position_index),
        Piece.defenders(piece.position_index, pieces).present?
      ].any?
    end

    target_pieces = pieces.select { |piece| targets.include?(piece.position_index) }

    target_pieces.reduce(0) do |total, piece|
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
end
