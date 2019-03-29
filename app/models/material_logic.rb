class MaterialLogic

  MATERIAL_VALUE = { pawn: 1, knight: 3, bishop: 3, rook: 5, queen: 9, king: 0 }

  def self.create_signature(new_pieces, game_turn_code)
    new_pieces.reduce(0) do |total, piece|
      if piece.color == 'black'
        total - MATERIAL_VALUE[piece.piece_type.to_sym]
      else
        total + MATERIAL_VALUE[piece.piece_type.to_sym]
      end
    end.to_s + game_turn_code
  end
end
