class PawnStructureLogic
  def self.create_signature(new_pieces, game_turn_code)
    new_pieces.select { |piece| piece.piece_type == 'pawn' }.reduce(0) do |total, pawn|
      binding.pry if total.nil?
      if Piece.defenders(pawn.position_index, new_pieces).size == 0
        if pawn.color == 'white'
          total + 1
        else
          total - 1
        end
      end
      total
    end.to_s + game_turn_code
  end
end
