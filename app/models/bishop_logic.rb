class BishopLogic
  def self.create_signature(setup_data)
    bishops = setup_data.pieces.select { |piece| piece.piece_type == 'bishop' }
    setup_data.calculate_piece_quality(bishops)
  end
end
