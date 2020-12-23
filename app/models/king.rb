class King
  def self.build(piece, king)
    if king.present?
      king.move_potential.map do |space|
        if piece.valid_moves.include?(space)
          piece.piece_type + 'v' + space
        elsif piece.move_potential.include?(space)
          piece.piece_type + 'm' + space
        else
          ''
        end
      end.join
    else
      ''
    end
  end
end
