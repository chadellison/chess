class ActivityLogic
  ACTIVITY_KEY = { king: 8, queen: 27, rook: 14, bishop: 13, knight: 8, pawn: 4 }

  def self.create_signature(new_pieces)
    new_pieces.reduce(0) do |sum, piece|
      total_possible = ACTIVITY_KEY[piece.piece_type.to_sym]
      left_over = (total_possible - piece.valid_moves(new_pieces).size)

      if piece.color == 'white'
        sum + total_possible - left_over
      else
        sum - total_possible - left_over
      end
    end.to_s
  end
end
