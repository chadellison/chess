class RookLogic
  def self.create_signature(setup_data)
    rooks = setup_data.pieces.select { |piece| piece.piece_type == 'rook' }
    setup_data.calculate_piece_quality(rooks)
  end
end
