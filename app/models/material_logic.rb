class MaterialLogic
  def self.create_signature(game_data, pieces_to_evaluate)
    return 0 if pieces_to_evaluate.blank?
    old_material_value = game_data.material_value[pieces_to_evaluate.first.piece_type].to_i
    new_material_value = find_material_value(pieces_to_evaluate)

    return 0 if old_material_value == new_material_value

    old_material_value > new_material_value ? -1 : 1
  end

  def self.find_material_value(pieces_to_evaluate)
    pieces_to_evaluate.reduce(0) do |total, piece|
      if piece.color == 'white'
        total + 1
      else
        total - 1
      end
    end
  end
end
