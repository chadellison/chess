class PawnLogic
  def self.create_signature(game_data)
    pawns = game_data.pieces.select { |piece| piece.piece_type == 'pawn' }
    pawn_quality = game_data.calculate_piece_quality(pawns)
  end
end
