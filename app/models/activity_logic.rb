class ActivityLogic
  def self.create_signature(new_pieces)
    signature = {}
    new_pieces.each do |piece|
      valid_moves = piece.valid_moves(new_pieces)

      if valid_moves.present?
        if signature[piece.find_piece_code].present?
          signature[piece.find_piece_code] += valid_moves.count
        else
          signature[piece.find_piece_code] = valid_moves.count
        end
      end
    end

    signature.map { |index, count| "#{index}-#{count}" }.join('.')
  end
end
