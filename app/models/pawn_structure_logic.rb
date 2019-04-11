class PawnStructureLogic
  def self.create_signature(new_pieces)
    white_pawn_weaknesses = 0
    black_pawn_weaknesses = 0

    new_pieces.select { |piece| piece.piece_type == 'pawn' }.each do |pawn|
      undefended = Piece.defenders(pawn.position_index, new_pieces).size == 0
      if undefended
        if pawn.color == 'white'
          white_pawn_weaknesses += 1
        else
          black_pawn_weaknesses += 1
        end
      end
    end

    return '0.0' if white_pawn_weaknesses == 0 || black_pawn_weaknesses == 0
    (white_pawn_weaknesses.to_f / black_pawn_weaknesses.to_f).round(3).to_s
  end
end
