class ActivitySignature
  def self.create_signature(new_pieces)
    signature = {}
    new_pieces.each do |piece|
      if signature[piece.find_piece_code].present?
        signature[piece.find_piece_code] += piece.valid_moves(new_pieces).count
      else
        signature[piece.find_piece_code] = piece.valid_moves(new_pieces).count
      end
    end

    signature.map do |index, count|
      "#{index}-#{count}"
    end.join('.')
  end
end
