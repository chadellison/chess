class ThreatLogic
  def self.create_signature(new_pieces)
    spaces_near_black_king = king_spaces(new_pieces, 5)
    spaces_near_white_king = king_spaces(new_pieces, 29)

    new_pieces.reduce(0) do |sum, piece|
      if can_threaten?(spaces_near_black_king, piece, new_pieces)
        sum + 1
      elsif can_threaten?(spaces_near_white_king, piece, new_pieces)
        sum - 1
      else
        sum
      end
    end
  end

  def self.can_threaten?(king_spaces, attacker, pieces)
    attacker.valid_moves.any? { |space| king_spaces.include?(space) } &&
      pieces.none? { |piece| piece.enemy_targets.include?(attacker.position_index) }
  end

  def self.king_spaces(new_pieces, king_index)
    new_pieces.detect do |piece|
      piece.position_index == king_index
    end.spaces_near_king
  end
end
