class RookLogic
  def self.create_signature(game_data)
    rooks = game_data.pieces.select { |piece| piece.piece_type == 'rook' }
    game_data.calculate_piece_quality(rooks)
  end
end
