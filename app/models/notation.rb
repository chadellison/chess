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
    new_notation + '.'
  end

  def find_move_position(move_notation, turn, pieces)
    if move_notation.include?('=')
      move_notation[-4..-3]
    elsif move_notation.include?('O')
      king = pieces.detect do |piece|
        piece.piece_type == 'king' && piece.color == turn
      end
      column = move_notation == 'O-O' ? 'g' : 'c'
      column + king.position[1]
    else
      move_notation[-2..-1]
    end
  end

  def upgrade_value(move_notation)
    piece_code = move_notation[-1]
    PIECE_CODE.invert[piece_code].to_s if move_notation.include?('=')
  end

  def find_piece(move_notation, turn, pieces)
    piece = piece_from_crossed_pawn(move_notation, turn, pieces) if move_notation.include?('=')

    piece = piece_from_castle(turn, pieces) if move_notation.include?('O')
    return piece if piece.present?

    piece_type = find_piece_type(move_notation)
    game_pieces = matching_pieces(piece_type, turn, move_notation[-2..-1], pieces)

    if game_pieces.count == 1
      game_pieces.first
    else
      notation_without_type = piece_type == 'pawn' ? move_notation : move_notation[1..-1]
      piece_from_start(game_pieces, notation_without_type.sub('x', '')[0])
    end
  end

  def log_error(move_notation, turn)
    puts 'ERROR #######################'
    puts 'NOTATION: ' + game.notation
    puts 'MOVE: ' + move_notation + ' ' + turn
    puts 'GAME ID: ' + game.id.to_s
  end

  def piece_from_start(game_pieces, starting_notation)
    game_pieces.detect do |game_piece|
      game_piece.position.include?(starting_notation)
    end
  end

  def piece_from_castle(turn, pieces)
    pieces.detect { |piece| piece.piece_type == 'king' && piece.color == turn }
  end

  def piece_from_crossed_pawn(move_notation, turn, pieces)
    if move_notation.include?('x')
      pawns = matching_pieces('pawn', turn, move_notation[-4..-3], pieces)
      pawns.detect { |pawn| pawn.position.include?(move_notation[0]) }
    else
      start_row = move_notation[1] == '8' ? '7' : '2'
      pieces.detect { |piece| piece.position == (move_notation[0] + start_row) }
    end
  end

  def find_piece_type(move_notation)
    return 'knight' if move_notation.include?('N')
    return 'bishop' if move_notation.include?('B')
    return 'queen' if move_notation.include?('Q')
    return 'rook' if move_notation.include?('R')
    return 'king' if move_notation.include?('K')
    'pawn'
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
