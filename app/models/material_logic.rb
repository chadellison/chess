class MaterialLogic
  def self.create_signature(setup_data)
    setup_data.pieces.reduce(0) do |total, piece|
      if setup_data.turn == piece.color && setup_data.targets.include?(piece.position_index)
        total
      else
        piece_value = piece.find_piece_value
        if piece.color == 'white'
          total + piece_value
        else
          total - piece_value
        end
      end
    end
  end
end
