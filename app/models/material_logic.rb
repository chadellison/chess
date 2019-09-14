class MaterialLogic
  MAX_MATERIAL_GAIN = 9.0

  def self.create_signature(game_data)
    current_material_value = find_material_value(game_data.opponents)
    difference = game_data.material_value - current_material_value

    return 0 if difference <= 0

    (difference.to_f / MAX_MATERIAL_GAIN).round(1)
  end

  def self.find_material_value(pieces)
    pieces.reduce(0) { |total, piece| total + piece.find_piece_value }
  end
end
