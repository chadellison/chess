class CheckLogic
  def self.create_signature(game_data)
    pieces = game_data[:pieces]

    targets = pieces.map(&:enemy_targets).flatten

    pieces.reduce(0) do |sum, piece|
      if can_check?(5, piece, pieces, targets)
        sum + 1
      elsif can_check?(29, piece, pieces, targets)
        sum - 1
      else
        sum
      end
    end
  end

  def self.can_check?(king_index, attacker, pieces, targets)
    attacker.enemy_targets.include?(king_index) &&
      !targets.include?(attacker.position_index)
  end
end
