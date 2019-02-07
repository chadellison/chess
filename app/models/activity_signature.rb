class ActivitySignature
  def self.create_signature(new_pieces)
    activity_signature = new_pieces.reduce(0) do |sum, piece|
      if piece.color == 'white'
        sum + 1 if piece.position[1].to_i > 4
        sum + piece.valid_moves(new_pieces).count
      else
        sum - 1 if piece.position[1].to_i < 5
        sum - piece.valid_moves(new_pieces).count
      end
    end
    activity_signature.to_s
  end
end
