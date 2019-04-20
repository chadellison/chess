class AttackLogic
  VALUE_BY_INDEX = {
    1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 0, 6 => 3, 7 => 3, 8 => 5, 9 => 1,
    10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => 1,
    18 => 1, 19 => 1, 20 => 1, 21 => 1, 22 => 1, 23 => 1, 24 => 1, 25 => 5,
    26 => 3, 27 => 3, 28 => 9, 29 => 0, 30 => 3, 31 => 3, 32 => 5
  }

  def self.create_signature(new_pieces, game_turn_code)
    attackers = new_pieces.select { |piece| piece.enemy_targets.present? }

    attackers.reduce(0) do |total, attacker|
      total + attacker.enemy_targets.reduce(0) do |sum, target|
        sum + VALUE_BY_INDEX[target]
        sum - Piece.defenders(target, new_pieces).size * attacker.find_piece_value
      end
    end.to_s + game_turn_code
  end
end
