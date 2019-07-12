class ExposedLogic
  def self.create_signature(game_data)
    pieces = game_data[:pieces]

    white_king = pieces.detect { |piece| piece.position_index == 29 }
    black_king = pieces.detect { |piece| piece.position_index == 5 }

    white_exposure = evaluate_exposure(white_king) ? -1 : 0
    black_exposure = evaluate_exposure(black_king) ? 1: 0
    white_exposure + black_exposure
  end

  def self.evaluate_exposure(king)
    king.has_moved && !['c', 'g'].include?(king.position[0])
  end
end
