class ActivityLogic
  def self.create_signature(game_data, pieces_to_evaluate)
    pieces_to_evaluate.reduce(0) do |total, piece|
      if piece.color == 'white'
        total + piece.valid_moves.size
      else
        total - piece.valid_moves.size
      end
    end
  end
end
