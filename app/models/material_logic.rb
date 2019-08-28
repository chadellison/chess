class MaterialLogic
  def self.create_signature(game_data)
    game_data.material_value - find_material_value(game_data.opponents)
  end

  def self.find_material_value(pieces)
    pieces.reduce(0) { |total, piece| total + piece.find_piece_value }
  end
end
