class PinLogic
  def self.pin_pattern(game_data)
    ally_pinners = game_data.allies.select do |ally|
      ['bishop', 'rook', 'queen'].include?(ally.piece_type)
    end

    opponent_pinners = game_data.opponents.select do |ally|
      ['bishop', 'rook', 'queen'].include?(ally.piece_type)
    end

    numerator = ally_pinners.reduce(0) do |total, piece|
      total + calculate_pins(piece, game_data.opponents)
    end

    opponent_pin_value = opponent_pinners.reduce(0) do |total, piece|
      total + calculate_pins(piece, game_data.allies)
    end

    return 0.0 if numerator == 0.0
    x = (numerator.to_f / (numerator + opponent_pin_value).to_f).round(1)
    binding.pry if x.blank?
    (numerator.to_f / (numerator + opponent_pin_value).to_f).round(1)
  end

  def self.calculate_pins(piece, opponent_pieces)
    opponent_pieces.reduce(0) do |total, opponent|
      if piece.moves_for_piece.include?(opponent.position)
        total + opponent.find_piece_value
      else
        total
      end
    end
  end
end
