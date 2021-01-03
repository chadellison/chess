class Pawn
  def self.create_center_abstraction(all_pieces, turn)
    value = 0
    all_pieces.each do |piece|
      if piece.piece_type.downcase == 'p'
        if piece.color == 'w' && ['d2', 'e2'].include?(piece.position)
          value -= 1
        end
        if piece.color == 'b' && ['d7', 'e7'].include?(piece.position)
          value += 1
        end
      end
    end

    turn == 'w' ? -value : value
  end

  def self.past_pawn_abstraction(all_pieces, turn)
    column_key = {}
    all_pieces.each do |piece|
      if piece.piece_type.downcase == 'p'
        value = column_key[piece.position[0]]
        if value.blank?
          column_key[piece.position[0]] = piece.piece_type == 'P' ? 1 : -1
        elsif value == 1 && piece.piece_type == 'p'
          column_key[piece.position[0]] = 0
        elsif value == -1 && piece.piece_type == 'P'
          column_key[piece.position[0]] = 0
        end
      end
    end

    result = column_key.values.sum
    turn == 'w' ? -result : result
  end
end
