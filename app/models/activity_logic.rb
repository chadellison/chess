class ActivityLogic
  def self.create_signature(game_data)
    ally_move_count = 0
    total_move_count = 0
    non_target_pieces = game_data.pieces.reject do |piece|
      game_data.targets.include?(piece.position_index)
    end

    non_target_pieces.each do |piece|
      move_count = piece.valid_moves.size
      if piece.color == game_data.turn
        ally_move_count += move_count
      end
      total_move_count += move_count
    end

    (ally_move_count.to_f / total_move_count.to_f).round(1)
  end
end
