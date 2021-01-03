class King
  def self.create_abstraction(target_positions, pieces, next_pieces, all_pieces, color)
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

  def self.potential_mate_abstraction(target_positions, pieces, next_pieces, all_pieces, color, next_fen)
    return 0 if pieces.blank?
    king = find_king(all_pieces, color)
    king_spaces = ChessValidator::MoveLogic.spaces_near_king(king.position)

    next_pieces.reduce(0) do |sum, piece|
      if target_positions.include?(piece.position)
        sum
      else
        sum + recapture_rank(piece, king_spaces, next_fen)
      end
    end * 0.1
  end

  def self.recapture_rank(piece, king_spaces, fen_notation)
    (piece.valid_moves & king_spaces).reduce(0) do |total, move|
      next_fen = ChessValidator::Engine.move(piece, move, fen_notation)
      after_attack_pieces = ChessValidator::Engine.find_next_moves(next_fen)
      if after_attack_pieces.none? { |opp| opp.valid_moves.include?(move) }
        total + 1
      else
        total
      end
    end
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

  def self.find_king(pieces, color)
    pieces.detect do |piece|
      piece.piece_type.downcase == 'k' && piece.color == color
    end
  end
end
