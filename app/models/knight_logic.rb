class KnightLogic
  def self.create_signature(setup_data)
    knights = setup_data.pieces.select { |piece| piece.piece_type == 'knight' }
    setup_data.calculate_piece_quality(knights)
  end
end
