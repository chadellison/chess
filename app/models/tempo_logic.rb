class TempoLogic
  VALUE_BY_INDEX = {
    1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 0, 6 => 3, 7 => 3, 8 => 5, 9 => 1,
    10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => -1,
    18 => -1, 19 => -1, 20 => -1, 21 => -1, 22 => -1, 23 => -1, 24 => -1, 25 => -5,
    26 => -3, 27 => -3, 28 => -9, 29 => 0, 30 => -3, 31 => -3, 32 => -5
  }

  def self.create_signature(new_pieces, game_turn_code)
    max_white_target = nil
    max_black_target = nil

    new_pieces.each do |piece|
      if piece.enemy_targets.present?
        current_target = piece.enemy_targets.max_by { |target| VALUE_BY_INDEX[target] }
        if piece.color == 'white'
          max_black_target = current_target if VALUE_BY_INDEX[current_target] > max_black_target
        else
          max_white_target = current_target if VALUE_BY_INDEX[current_target] > max_white_target
        end
      end
    end

    max_white_target.to_s + max_black_target.to_s + game_turn_code
  end
end
