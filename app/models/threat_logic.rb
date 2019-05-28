class ThreatLogic
  def self.create_signature(new_pieces)
    new_pieces.reduce(0) do |sum, piece|
      if can_check_without_being_attacked(5, piece, new_pieces)
        sum + 1
      elsif can_check_without_being_attacked(29, piece, new_pieces)
        sum - 1
      else
        sum
      end
    end
  end

  def self.can_check_without_being_attacked(king_index, attacker, pieces)
    attacker.enemy_targets.include?(king_index) &&
      pieces.none? { |piece| piece.enemy_targets.include?(attacker.position_index) }
  end
end
