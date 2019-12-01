class LastMoveLogic
  DENOMINATOR = 9.0

  def self.last_move_defense_pattern(game_data)
    # if game_data.moved_piece.blank?
    #   puts 'en passant issue....!!!!!!!'
    #   return 0.0
    # end
    #
    # if game_data.targets.include?(game_data.moved_piece.position_index)
    #   difference = game_data.material_value - MaterialLogic.find_material_value(game_data.pieces)
    #   defense_value = DefenseLogic.target_defense_value(game_data.pieces, game_data.moved_piece, game_data.defender_index)
    #   difference + defense_value > 0 ? 1.0 : 0
    # else
    #   1.0
    # end
    0.0
  end

  # def self.last_move_general_defense_pattern(game_data)
  #   if game_data.moved_piece.blank?
  #     puts 'en passant issue....!!!!!!!'
  #     return 0.0
  #   end
  #
  #   game_data.defender_index[game_data.moved_piece.position_index].present? ? 1.0 : 0.0
  # end

  def self.last_move_offense_pattern(game_data)
    # moved_piece = game_data.moved_piece
    # if moved_piece.blank?
    #   puts 'en passant issue....!!!!!!!'
    #   return 0.0
    # end
    #
    # return 0.0 if game_data.targets.include?(moved_piece.position_index)
    #
    # vulnerable_opponents = game_data.opponent_targets.select do |opponent|
    #   moved_piece.enemy_targets.include?(opponent.position_index) &&
    #   (moved_piece.find_piece_value < opponent.find_piece_value || game_data.defender_index[opponent.position_index].blank?)
    # end
    # vulnerable_opponents.size.to_f
    0.0
  end
end
