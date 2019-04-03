class AttackLogic

  VALUE_FROM_INDEX = {
    1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 10, 6 => 3, 7 => 3, 8 => 5, 9 => 1,
    10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => 1,
    18 => 1, 19 => 1, 20 => 1, 21 => 1, 22 => 1, 23 => 1, 24 => 1, 25 => 5,
    26 => 3, 27 => 3, 28 => 9, 29 => 10, 30 => 3, 31 => 3, 32 => 5
  }

  def self.create_signature(new_pieces, game_turn_code)
    pieces_with_targets = new_pieces.select { |piece| piece.enemy_targets.present? }

    find_target_by_color(pieces_with_targets, 'white') + 'x' +
      find_target_by_color(pieces_with_targets, 'black') + game_turn_code
  end

  def self.find_target_by_color(pieces_with_targets, color)
    target = ''
    max_value = 0

    pieces_with_targets.select { |piece| piece.color == color }.each do |piece|
      target_index = piece.enemy_targets.max_by { |index| VALUE_FROM_INDEX[index] }
      target = target_index if VALUE_FROM_INDEX[target_index] > max_value
    end
    target.to_s
  end
end
