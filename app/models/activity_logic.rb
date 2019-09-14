class ActivityLogic
  def self.activity_pattern(game_data)
    return 0 if game_data.targets.include?(5) || game_data.targets.include?(29)

    ally_move_count = 0
    total_move_count = 0

    game_data.pieces.each do |piece|
      move_count = piece.valid_moves.size
      if piece.color == game_data.turn
        ally_move_count += move_count
      end
      total_move_count += move_count
    end
    (ally_move_count.to_f / total_move_count.to_f).round(1)
  end
end
