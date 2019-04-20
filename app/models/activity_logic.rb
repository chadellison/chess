class ActivityLogic
  def self.create_signature(new_pieces, game_turn_code)
    new_pieces.reduce(0) do |total, piece|
      move_count = piece.valid_moves(new_pieces).size
      if piece.color == 'white'
        total + move_count
      else
        total - move_count
      end
    end.to_s + game_turn_code
  end
end
