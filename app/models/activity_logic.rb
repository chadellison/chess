class ActivityLogic
  def self.find_pattern(game_data)
    most_active_pieces = game_data.pieces.sort_by do |piece|
      piece.valid_moves.size
    end.first(8)
    Signature.create_signature(most_active_pieces, game_data.turn[0])
  end

  def self.general_activity(game_data)
    most_active_pieces = game_data.pieces.sort_by do |piece|
      piece.valid_moves.size
    end.first(8)
    most_active_pieces.map(&:find_piece_code).join('.') + game_data.turn[0]
  end
end
