class KnightLogic
  def self.create_signature(game_data)
    knights = game_data.pieces.select { |piece| piece.piece_type == 'knight' }
    game_data.calculate_piece_quality(knights)
  end
end
