class MaterialSignature
  def self.create_signature(new_pieces, game_turn_code)
    white_pieces = new_pieces.select { |piece| piece.color == 'white' }
    black_pieces = new_pieces.select { |piece| piece.color == 'black' }

    white_value = white_pieces.reduce(0) { |sum, piece| sum + piece.find_piece_value }
    black_value = black_pieces.reduce(0) { |sum, piece| sum + piece.find_piece_value }
    (white_value - black_value).to_s + game_turn_code
  end
end
