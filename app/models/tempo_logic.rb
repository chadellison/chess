class TempoLogic
  def self.tempo_pattern(game_data)
    0
  end

  def self.pawn_pattern(game_data)
    # must be different for pawns
    # (1.0 - calculate_tempo(game_data, game_data.pawns)).round(1)

  end

  def self.knight_pattern(game_data)
    (1.0 - calculate_tempo(game_data, game_data.knights)).round(1)
  end

  def self.bishop_pattern(game_data)
    (1.0 - calculate_tempo(game_data, game_data.bishops)).round(1)
  end

  def self.rook_pattern(game_data)
    (1.0 - calculate_tempo(game_data, game_data.rooks)).round(1)
  end

  def self.queen_pattern(game_data)
    (1.0 - calculate_tempo(game_data, game_data.queens)).round(1)
  end

  def self.calculate_tempo(game_data, pieces)
    ally_valid_moves = game_data.allies.map(&:valid_moves).flatten
    ally_spaces = game_data.allies.map(&:position)
    all_spaces = ally_spaces + game_data.opponents.map(&:position)

    attacked = []
    pieces.each do |piece|
      if piece.color == game_data.opponent_color
        (piece.valid_moves - ally_valid_moves).each do |move|
          theoretical_piece = piece.clone
          theoretical_piece.position = move
          with_tempo = theoretical_piece.moves_for_piece.select do |m|
            ally_piece = game_data.allies.detect { |ally| ally.position == m }
            ally_piece.present? &&
              theoretical_piece.valid_move_path?(m, all_spaces) &&
              (game_data.defender_index[ally_piece.position_index].blank? || ally_piece.find_piece_value > theoretical_piece.find_piece_value)
          end

          game_data.allies.each do |ally|
            if with_tempo.include?(ally.position)
              attacked << ally.find_piece_value
            end
          end
        end
      end
    end

    numerator = attacked.sum.to_f
    denominator = game_data.allies.map(&:find_piece_value).sum
    return 0.0 if numerator == 0.0 || denominator == 0.0
    return 1 if numerator > denominator
    (numerator / denominator)
  end
end
