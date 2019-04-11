class MaterialLogic
  INITIAL_VALUE = 0.01

  def self.create_signature(new_pieces)
    white_material = INITIAL_VALUE
    black_material = INITIAL_VALUE

    new_pieces.each do |piece|
      piece_value = piece.find_piece_value

      if piece.color == 'white'
        white_material += piece_value
      else
        black_material += piece_value
      end
    end

    (white_material / black_material).round(3).to_s
  end
end
