class MaterialLogic
  MATERIAL_VALUE = { 1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 0, 6 => 3, 7 => 3, 8 => 5,
    9 => 1, 10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => 1,
    18 => 1, 19 => 1, 20 => 1, 21 => 1, 22 => 1, 23 => 1, 24 => 1, 25 => 5, 26 => 3,
    27 => 3, 28 => 9, 29 => 0, 30 => 3, 31 => 3, 32 => 5
  }

  def self.find_value(index)
    MATERIAL_VALUE[index]
  end

  def self.calculate_value(new_pieces, game_turn_code)
    enemy_attackers = new_pieces.select do |piece|
      piece.color[0] == game_turn_code && piece.enemy_targets.present?
    end

    enemy_attack_value = 0
    enemy_attackers.each do |piece|
      value = find_value(piece.enemy_targets.max_by { |target| find_value(target) })
      enemy_attack_value = value if value > enemy_attack_value
    end

    enemy_attack_value *= -1 if game_turn_code == 'b'

    material_value = new_pieces.reduce(0) do |total, piece|
      if piece.color == 'black'
        total - find_value(piece.position_index)
      else
        total + find_value(piece.position_index)
      end
    end

    material_value + enemy_attack_value
  end
end
