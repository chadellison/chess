class ActivityLogic
  def self.create_signature(game_data)
    game_data.allies.reduce(0) { |total, piece| total + piece.valid_moves.size }
  end
end
