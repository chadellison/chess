class MaterialLogic
  def self.create_signature(new_pieces, game_turn_code)
    new_pieces.reduce(0) do |total, piece|
      piece_value = piece.find_piece_value

      if piece.color == 'white'
        total + piece_value
      else
        total - piece_value
      end
    end.to_s + game_turn_code
  end
end
