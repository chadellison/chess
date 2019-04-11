class ActivityLogic
  INITIAL_VALUE = 0.01

  def self.create_signature(new_pieces)
    white_activity = INITIAL_VALUE
    black_activity = INITIAL_VALUE

    new_pieces.each do |piece|
      if piece.color == 'white'
        white_activity += piece.valid_moves(new_pieces).size
      else
        black_activity += piece.valid_moves(new_pieces).size
      end
    end

    (white_activity / black_activity).round(3).to_s
  end
end
