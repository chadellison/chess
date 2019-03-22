class ActivityLogic
  def self.create_signature(new_pieces, game_turn_code)
    white_activity = 0
    black_activity = 0
    new_pieces.each do |piece|
      if piece.color == 'white'
        white_activity += piece.valid_moves(new_pieces).size
      else
        black_activity += piece.valid_moves(new_pieces).size
      end
    end

    (white_activity / black_activity.to_f).to_s + game_turn_code
  end
end
