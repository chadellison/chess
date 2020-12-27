class King
  def self.create_abstraction(pieces, next_pieces, all_pieces)
    target_positions = find_target_positions(pieces)
    king = find_king(all_pieces, pieces.first.color)
    king_spaces = ChessValidator::MoveLogic.spaces_near_king(king.position)

    next_pieces.reduce(0) do |sum, piece|
      if target_positions.include?(piece.position)
        sum + 0
      else
        king_threat_count = (piece.valid_moves & king_spaces).size
        sum + king_threat_count * AbstractionHelper.find_piece_value(piece)
      end
    end * 0.1
  end

  def self.find_target_positions(pieces)
    pieces.reduce([]) do |accumulator, piece|
      accumulator + piece.targets.map(&:position)
    end.uniq
  end

  def self.find_king(pieces, color)
    pieces.detect do |piece|
      piece.piece_type.downcase == 'k' && piece.color == color
    end
  end
end
