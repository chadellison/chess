class CenterLogic
  CENTER_SQUARES = [
    'c6', 'd6', 'e6', 'f6', 'c5', 'd5', 'e5', 'f5', 'c4', 'd4', 'e4', 'f4',
    'c3', 'd3', 'e3', 'f3'
  ]

  def self.find_pattern(game_data)
    center_pieces = game_data.pieces.select do |piece|
      CENTER_SQUARES.include?(piece.position)
    end
    Signature.create_signature(center_pieces, game_data.turn[0])
  end
end
