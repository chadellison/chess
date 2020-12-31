class King
  def self.create_abstraction(pieces, next_pieces, all_pieces, color)
    target_positions = find_target_positions(pieces)
    return 0 if pieces.blank?
    king = find_king(all_pieces, color)
    king_spaces = ChessValidator::MoveLogic.spaces_near_king(king.position)

    next_pieces.reduce(0) do |sum, piece|
      if target_positions.include?(piece.position)
        sum + 0
      else
        sum + (piece.valid_moves & king_spaces).size
      end
    end * 0.1
  end

  def self.create_threat_abstraction(pieces, next_pieces, all_pieces, color, fen_notation)
    return 0 if next_pieces.blank?
    ally_king = find_king(all_pieces, color == 'w' ? 'b' : 'w')
    king_spaces = ChessValidator::MoveLogic.spaces_near_king(ally_king.position)

    sum = 0
    pieces.each do |piece|
      piece.valid_moves.each do |move|
        if king_spaces.include?(move)
          new_fen_notation = ChessValidator::Engine.move(piece, move, fen_notation)
          pieces_with_moves = ChessValidator::Engine.find_next_moves(new_fen_notation)
          if pieces_with_moves.none? { |p| p.valid_moves.include?(move) }
            sum -= 1
          end
        end
      end
    end
    sum * 0.1
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
