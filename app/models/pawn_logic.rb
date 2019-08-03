class PawnLogic
  def self.create_signature(setup_data)
    pawns = setup_data.pieces.select { |piece| piece.piece_type == 'pawn' }
    pawn_quality = setup_data.calculate_piece_quality(pawns)
  end
end
