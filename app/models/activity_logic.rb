class ActivityLogic
  def self.create_signature(game_data)
    return 0 if game_data.targets.any? { |target| [5, 29].include?(target) }

    game_data.pieces.reduce(0) do |total, piece|
      move_count = piece.valid_moves.size
      if piece.color == 'white'
        total + move_count
      else
        total - move_count
      end
    end
  end
end
