class MaterialLogic
  def self.material_pattern(game_data)
    current_material_value = find_material_value(game_data.opponents)
    difference = game_data.material_value - current_material_value

    return 0.0 if difference == 0

    moved_piece = game_data.moved_piece

    if game_data.targets.include?(moved_piece.position_index)
      defense_value = DefenseLogic.defense_value(game_data.pieces, game_data.ally_targets)
      material_value = difference + defense_value
      return 0.0 if material_value < 0
      material_value.to_f
    else
      difference.to_f
    end
  end

  def self.find_material_value(pieces)
    pieces.reduce(0) { |total, piece| total + piece.find_piece_value }
  end
end
