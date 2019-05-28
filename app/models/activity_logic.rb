class ActivityLogic
  def self.create_signature(new_pieces)
    new_pieces.reduce(0) do |total, piece|
      move_count = piece.valid_moves.size
      if piece.color == 'white'
        total + move_count
      else
        total - move_count
      end
    end
  end
end
