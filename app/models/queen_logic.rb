class QueenLogic
  def self.create_signature(game_data)
    queens = game_data.pieces.select { |piece| piece.piece_type == 'queen' }
    game_data.calculate_piece_quality(queens)
  end
end
