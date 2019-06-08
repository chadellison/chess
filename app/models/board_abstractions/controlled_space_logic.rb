class ControlledSpaceLogic
  def self.create_signature(game_data)
    valid_moves_with_counts = {}

    game_data[:pieces].each do |piece|
      piece.valid_moves.each do |move|
        increment_value = piece.color == 'white' ? 1 : -1

        if valid_moves_with_counts[move].present?
          valid_moves_with_counts[move] += increment_value
        else
          valid_moves_with_counts[move] = increment_value
        end
      end
    end

    valid_moves_with_counts.values.reduce(0, :+)
  end
end
