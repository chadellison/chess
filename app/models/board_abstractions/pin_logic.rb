class PinLogic
  TARGET_VALUE = {
    1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 0, 6 => 3, 7 => 3, 8 => 5, 9 => 1,
    10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => 1,
    18 => 1, 19 => 1, 20 => 1, 21 => 1, 22 => 1, 23 => 1, 24 => 1, 25 => 5,
    26 => 3, 27 => 3, 28 => 9, 29 => 0, 30 => 3, 31 => 3, 32 => 5
  }

  def self.create_signature(game_data)
    pieces = game_data[:pieces]

    pieces.reduce(0) do |sum, piece|
      if piece.piece_type != 'pawn' && piece.enemy_targets.present?
        without_targets = pieces.reject do |game_piece|
          piece.enemy_targets.include?(game_piece.position_signature)
        end
        cloned_piece = piece.clone

        cloned_piece.valid_moves.each do |move|
          load_enemy_targets(move, without_targets, cloned_piece)
        end

        pin_value = cloned_piece.enemy_targets.reduce(0) do |total, target_id|
          total + TARGET_VALUE[target_id]
        end

        if piece.color == 'white'
          sum + pin_value
        else
          sum - pin_value
        end
      else
        sum
      end
    end
  end
end
