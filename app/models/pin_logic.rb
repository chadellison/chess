class PinLogic
  def self.find_pattern(game_data)
    opponent_king_space = game_data.opponent_king.position
    ally_king_space = game_data.ally_king.position

    numerator = 0
    total = 0
    game_data.pieces.each do |piece|
      if piece.color == game_data.turn
        if piece.moves_for_piece.include?(opponent_king_space)
          numerator += 1
          total += 1
        end
      end
      if piece.color != game_data.turn
        total += 1 if piece.moves_for_piece.include?(ally_king_space)
      end
    end

    (numerator.to_f / total.to_f).round(1)
  end
end
