class TempoLogic
  TEMPO_DENOMINATOR = 20.0

  def self.tempo_pattern(game_data)
    ally_attacking_moves = remove_pawn_advances(game_data.allies).uniq
    occupied_spaces = game_data.pieces.map(&:position)
    total_value = calculate_tempo(
      game_data,
      ally_attacking_moves,
      occupied_spaces
    )

    return 1.0 if total_value == 0
    return 0.0 if total_value > TEMPO_DENOMINATOR
    (1.0 - (total_value.to_f / TEMPO_DENOMINATOR)).round(1)
  end

  def self.calculate_tempo(game_data, ally_attacking_moves, occupied_spaces)
    total_value = 0
    game_data.opponents.each do |opponent|
      cloned_opponent = opponent.clone

      opponent.valid_moves.each do |move|
        if !ally_attacking_moves.include?(move) #|| target_defense_value here...
          cloned_opponent.position = move
          cloned_opponent_value = cloned_opponent.find_piece_value
          opponent_moves = next_moves(cloned_opponent, occupied_spaces)
          tempo_value = tempo_value(game_data, opponent_moves, cloned_opponent_value)
          total_value = tempo_value if tempo_value > total_value
        end
      end
    end
    total_value
  end

  def self.tempo_value(game_data, opponent_moves, cloned_opponent_value)
    multiplyer = 0
    tempo_value = game_data.allies.reduce(0) do |sum, ally|
      if opponent_moves.include?(ally.position)
        if game_data.defender_index[ally.position_index].present?
          difference = ally.find_piece_value - cloned_opponent_value
          if difference > 0
            multiplyer += 1
            sum + difference
          else
            sum
          end
        else
          multiplyer += 1
          sum + ally.find_piece_value
        end
      else
        sum
      end
    end

    tempo_value * multiplyer
  end

  def self.remove_pawn_advances(pieces)
    # maybe handle castle here too
    pieces.map do |piece|
      if piece.piece_type == 'pawn'
        handle_pawn(piece.valid_moves, piece.position)
      else
        piece.valid_moves
      end
    end.flatten
  end

  def self.handle_pawn(moves, position)
    moves.reject { |move| move[0] == position[0] }
  end

  def self.next_moves(piece, occupied_spaces)
    opponent_moves = piece.moves_for_piece
    if piece.piece_type == 'pawn'
      opponent_moves = handle_pawn(piece.moves_for_piece, piece.position)
    end
    opponent_moves.select do |move|
      piece.valid_move_path?(move, occupied_spaces)
    end
  end
end
