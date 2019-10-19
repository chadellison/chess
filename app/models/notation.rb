class Notation
  PIECE_CODE = {
    king: 'K', queen: 'Q', bishop: 'B', knight: 'N', rook: 'R', pawn: ''
  }

  def create_notation(position_index, new_position, upgraded_type, pieces)
    piece = pieces.detect { |p| p.position_index == position_index }
    return castle_notation(new_position) if piece.king_moved_two?(new_position)
    new_notation = PIECE_CODE[piece.piece_type.to_sym]
    new_notation += start_notation(piece, new_position, pieces) unless ['king', 'queen'].include?(piece.piece_type)
    new_notation += capture_notation(new_notation, piece, new_position, pieces)
    new_notation += new_position
    new_notation += '=' + PIECE_CODE[upgraded_type.to_sym] if upgraded_type.present?
    new_notation
  end

  def castle_notation(new_position)
    new_position[0] == 'c' ? 'O-O-O.' : 'O-O.'
  end

  def start_notation(piece, next_move, pieces)
    same_pieces = matching_pieces(piece.piece_type, piece.color, next_move, pieces)
    return '' if same_pieces.count < 2

    column_is_unique?(same_pieces, piece.position) ? piece.position[0] : piece.position[1]
  end

  def matching_pieces(piece_type, piece_color, new_position, pieces)
    pieces.select do |piece|
      piece.piece_type == piece_type &&
        piece.color == piece_color &&
        piece.valid_moves.include?(new_position)
    end
  end

  def capture_notation(notation, piece, new_position, pieces)
    if pieces.select { |piece| piece.position == new_position }.present?
      notation.blank? ? piece.position[0] + 'x' : 'x'
    else
      ''
    end
  end

  def column_is_unique?(same_pieces, position)
    same_pieces.select do |game_piece|
      game_piece.position[0] == position[0]
    end.count == 1
  end
end
