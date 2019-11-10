class DiagonalLogic
  def self.ally_diagonal_pattern(game_data)
    diagonal_pattern(game_data.allies, game_data.opponents)
  end

  def self.opponent_diagonal_pattern(game_data)
    diagonal_pattern(game_data.opponents, game_data.allies)
  end

  def self.diagonal_pattern(allies, opponents)
    bishops = allies.select { |p| p.piece_type == 'bishop' }

    return 0 if bishops.size == 2 || bishops.blank?

    bishop_color = [3, 30].include?(bishops[0].position_index) ? 'white' : 'black'

    matching_squares = opponents_on_squares(opponents, bishop_color)
    return 0 if matching_squares.blank?

    numerator = tally_piece_value(matching_squares).to_f
    denominator = tally_piece_value(opponents).to_f

    (numerator / denominator).round(1)
  end

  def self.tally_piece_value(pieces)
    pieces.reduce(0) do |total, opponent|
      total + opponent.find_piece_value
    end
  end

  def self.opponents_on_squares(opponents, color)
    opponents.select do |opponent|
      square_color(opponent.position) == color
    end
  end

  def self.square_color(position)
    square_value = ('a'..'h').to_a.index(position[0]) + position[1].to_i
    square_value.even? ? 'white' : 'black'
  end
end
