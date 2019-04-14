class PawnStructureLogic
  INITIAL_VALUE = 0.01

  def self.create_signature(new_pieces)
    white_pawn_weaknesses = INITIAL_VALUE
    black_pawn_weaknesses = INITIAL_VALUE

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

    (white_pawn_weaknesses / black_pawn_weaknesses).to_s
  end
end
