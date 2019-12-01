class TempoLogic
  TEMPO_DENOMINATOR = 10.0
  def self.tempo_pattern(game_data)
    tempo_value = 0
    selected_children = game_data.children.each do |child|
      material_value = MaterialLogic.find_material_value(child.opponents)
      difference = child.material_value - material_value
      moved_piece = child.allies.detect do |ally|
        ally.position_index == child.move.value.to_i
      end

      if !game_data.targets.include?(moved_piece.position_index)
        if !child.targets.include?(child.move.value.to_i)
          tempo_value += difference
        elsif difference > moved_piece.find_piece_value
          tempo_value += (difference - moved_piece.find_piece_value)
        end
      end
    end

    return 0.0 if tempo_value <= 0
    (tempo_value / TEMPO_DENOMINATOR).round(1)
  end
end
