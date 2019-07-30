class MaterialLogic
  def self.create_signature(game_data)
    game_data.pieces.reduce(0) do |total, piece|
      if game_data.turn == piece.color || !game_data.targets.include?(piece.position_index)
        piece_value = piece.find_piece_value
        if piece.color == 'white'
          total + piece_value
        else
          total - piece_value
        end
      else
        total
      end
    end
  end
end
