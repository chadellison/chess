class AttackLogic
  TARGET_VALUE = {
    1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 0, 6 => 3, 7 => 3, 8 => 5, 9 => 1,
    10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => 1,
    18 => 1, 19 => 1, 20 => 1, 21 => 1, 22 => 1, 23 => 1, 24 => 1, 25 => 5,
    26 => 3, 27 => 3, 28 => 9, 29 => 0, 30 => 3, 31 => 3, 32 => 5
  }

  def self.create_signature(new_pieces)
    new_pieces.select { |piece| piece.enemy_targets.present? }.reduce(0) do |sum, piece|
      max_target_id = piece.enemy_targets.max_by do |target_id|
        defended = Piece.defenders(target_id, new_pieces).present?
        recapture_cost = defended ? piece.find_piece_value : 0
        TARGET_VALUE[target_id] - recapture_cost
      end

      if piece.color == 'white'
        sum + TARGET_VALUE[max_target_id]
      else
        sum - TARGET_VALUE[max_target_id]
      end
    end
  end
end
