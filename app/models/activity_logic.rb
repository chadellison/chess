class ActivityLogic
  def self.create_signature(game_data, pieces_to_evaluate)
    signature_value = pieces_to_evaluate.reduce(0) do |total, piece|
      if piece.color == 'white'
        total + piece.valid_moves.size
      else
        total - piece.valid_moves.size
      end
    end

    return 1 if signature_value > 1
    return -1 if signature_value < -1
    0
  end
end
