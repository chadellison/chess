class BishopLogic
  def self.create_signature(game_data)
    bishops = game_data.pieces.select { |piece| piece.piece_type == 'bishop' }
    game_data.calculate_piece_quality(bishops)
  end
end
