class MaterialLogic
  def self.create_signature(new_pieces)
    white_material = 0
    black_material = 0

    new_pieces.each do |piece|
      piece_value = piece.find_piece_value

      if piece.color == 'white'
        white_material += piece_value
      else
        black_material += piece_value
      end
    end

    (white_material.to_f / black_material.to_f).round(3).to_s
  end
end
