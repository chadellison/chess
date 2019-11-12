class PawnLogic
  # def self.undefended_pawn_pattern(game_data)
  #   numerator = 0.0
  #   denominator = 0.0
  #
  #   game_data.pawns.each do |pawn|
  #     if game_data.defender_index[pawn.position_index].blank?
  #       numerator += 1 if pawn.color == game_data.opponent_color
  #       denominator += 1
  #     end
  #   end
  #
  #   return 0 if numerator == 0
  #   (numerator / denominator).round(1)
  # end
end
