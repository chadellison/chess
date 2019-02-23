class MaterialLogic
  def self.create_signature(new_pieces)
    white_pieces = new_pieces.select { |piece| piece.color == 'white' }
    black_pieces = new_pieces.select { |piece| piece.color == 'black' }

    white_value = white_pieces.reduce(0) { |sum, piece| sum + piece.find_piece_value }
    black_value = black_pieces.reduce(0) { |sum, piece| sum + piece.find_piece_value }

    material_difference = white_value - black_value
    material_difference.to_s if material_difference != 0
  end
end
