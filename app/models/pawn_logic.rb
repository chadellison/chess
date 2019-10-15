class PawnLogic
  def self.find_pattern(game_data)
    pawns = game_data.pieces.select do |piece|
      piece.piece_type == 'pawn'
    end
    Signature.create_signature(pawns, game_data.turn[0])
  end
end
