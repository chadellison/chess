class ThreatLogic
  def self.create_signature(game_data)
    pieces = game_data[:pieces]

    spaces_near_black_king = king_spaces(pieces, 5)
    spaces_near_white_king = king_spaces(pieces, 29)
    targets = pieces.map(&:enemy_targets).flatten

    pieces.reduce(0) do |sum, piece|
      if can_threaten?(spaces_near_black_king, piece, pieces, targets)
        sum + 1
      elsif can_threaten?(spaces_near_white_king, piece, pieces, targets)
        sum - 1
      else
        sum
      end
    end
  end

  def self.can_threaten?(king_spaces, attacker, pieces, targets)
    strategic_threat = attacker.valid_moves.any? do |space|
      king_spaces.include?(space) && space_control?(space, pieces, attacker.color)
    end

    strategic_threat && !targets.include?(attacker.position_index)
  end

  def self.space_control?(space, pieces, attacker_color)
    control_count = pieces.reduce(0) do |sum, piece|
      if piece.moves_for_piece.include?(space)
        if piece.color == 'white'
          sum + 1
        else
          sum - 1
        end
      else
        sum
      end
    end

    (control_count > 0 && attacker_color == 'white') || (control_count < 0 && attacker_color == 'black')
  end

  def self.king_spaces(pieces, king_index)
    pieces.detect { |piece| piece.position_index == king_index }.spaces_near_king
  end
end
