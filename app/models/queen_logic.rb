class QueenLogic
  def self.create_signature(setup_data)
    queens = setup_data.pieces.select { |piece| piece.piece_type == 'queen' }
    setup_data.calculate_piece_quality(queens)
  end
end
