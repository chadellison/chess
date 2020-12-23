class Pin
  def self.find_pinned(pieces, moves)
    pieces.map do |piece|
      if moves.include?(piece.position)
        piece.piece_type
      else
        ''
      end
    end
  end

  def self.build(piece, all_pieces)
    pinners = ['r', 'b', 'q']
    if pinners.include?(piece.piece_type.downcase)
      pinned = find_pinned(all_pieces, piece.move_potential)
      if pinned.present?
        "#{piece.piece_type}-#{pinned.join}"
      else
        ''
      end
    else
      ''
    end
  end
end
