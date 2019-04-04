class PawnStructureLogic
  def self.create_signature(new_pieces, game_turn_code)
    new_pieces.select { |piece| piece.piece_type == 'pawn' }
      .map(&:position).join + game_turn_code
  end
end
