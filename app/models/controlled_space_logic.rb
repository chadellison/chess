class ControlledSpaceLogic
  def self.create_signature(game_data)
    pieces = game_data[:pieces]
    moves_with_counts = {}

    white_moves = pieces.select { |piece| piece.color == 'white' }.map(&:valid_moves).flatten
    black_moves = pieces.select { |piece| piece.color == 'black' }.map(&:valid_moves).flatten

    shared_squares = white_moves & black_moves

    pieces.each do |piece|
      piece.valid_moves.each do |move|
        if shared_squares.include?(move)
          increment_value = piece.color == 'white' ? 1 : -1

          if moves_with_counts[move].present?
            moves_with_counts[move] += increment_value
          else
            moves_with_counts[move] = increment_value
          end
        end
      end
    end

    moves_with_counts.values.reduce(0) do |sum, value)
      if value > 0
        sum + 1
      elsif value < 0
        sum - 1
      else
        sum
      end
    end
  end
end
