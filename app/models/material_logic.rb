class MaterialLogic
  def self.create_signature(game_data)
    old_material_value = game_data.material_value
    new_material_value = find_material_value(game_data.pieces)

    return 0 if old_material_value == new_material_value

    difference = (old_material_value - new_material_value).abs
    if old_material_value > new_material_value
      difference * -1
    else
      difference
    end
  end

  def self.find_material_value(pieces)
    pieces.reduce(0) do |total, piece|
      if piece.color == 'white'
        total + piece.find_piece_value
      else
        total - piece.find_piece_value
      end
    end
  end
end
