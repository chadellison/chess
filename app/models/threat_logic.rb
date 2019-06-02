class ThreatLogic
  def self.create_signature(new_pieces)
    spaces_near_black_king = king_spaces(new_pieces, 5)
    spaces_near_white_king = king_spaces(new_pieces, 29)
    targets = new_pieces.map(&:enemy_targets).flatten

    new_pieces.reduce(0) do |sum, piece|
      if can_threaten?(spaces_near_black_king, piece, new_pieces, targets)
        sum + 1
      elsif can_threaten?(spaces_near_white_king, piece, new_pieces, targets)
        sum - 1
      else
        sum
      end
    end
  end

  def self.can_threaten?(king_spaces, attacker, pieces, targets)
    attacker.valid_moves.any? { |space| king_spaces.include?(space) } &&
      !targets.include?(attacker.position_index)
  end

  def self.king_spaces(pieces, king_index)
    pieces.detect { |piece| piece.position_index == king_index }.spaces_near_king
  end
end
