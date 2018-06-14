module NotationLogic
  extend ActiveSupport::Concern

  PIECE_CODE = {
    king: 'K', queen: 'Q', bishop: 'B', knight: 'N', rook: 'R', pawn: ''
  }

  def find_move_position(move_notation)
    if move_notation.include?('=')
      move_notation[-4..-3]
    elsif move_notation.include?('O')
      king = pieces.find_by(piece_type: 'king', color: current_turn)
      column = move_notation == 'O-O' ? 'g' : 'c'
      column + king.position[1]
    else
      move_notation[-2..-1]
    end
  end

  def update_game_from_notation(move_notation, turn)
    piece = find_piece(move_notation, turn)
    binding.pry if piece.blank?
    update_game(piece, find_move_position(move_notation), upgrade_value(move_notation))
  end

  def upgrade_value(move_notation)
    piece_code = move_notation[-1]
    PIECE_CODE.invert[piece_code].to_s if move_notation.include?('=')
  end

  def find_piece(move_notation, turn)
    piece = piece_from_crossed_pawn(move_notation, turn) if move_notation.include?('=')
    piece = piece_from_castle(turn) if move_notation.include?('O')
    return piece if piece.present?

    piece_type = find_piece_type(move_notation)
    game_pieces = matching_pieces(piece_type, turn, move_notation[-2..-1])

    if game_pieces.count == 1
      game_pieces.first
    else
      notation_without_type = piece_type == 'pawn' ? move_notation : move_notation[1..-1]
      piece_from_start(game_pieces, notation_without_type)
    end
  end

  def piece_from_start(game_pieces, notation_without_type)
    game_pieces.detect do |game_piece|
      game_piece.position.include?(notation_without_type[0])
    end
  end

  def piece_from_castle(turn)
    pieces.find_by(piece_type: 'king', color: turn)
  end

  def piece_from_crossed_pawn(move_notation, turn)
    if move_notation.include?('x')
      pawns = matching_pieces('pawn', turn, move_notation[-4..-3])
      pawns.detect { |pawn| pawn.position.include?(move_notation[0]) }
    else
      start_row = move_notation[1] == '8' ? '7' : '2'
      pieces.find_by(position: (move_notation[0] + start_row))
    end
  end

  def find_piece_type(move_notation)
    return 'king' if move_notation.include?('K')
    return 'queen' if move_notation.include?('Q')
    return 'bishop' if move_notation.include?('B')
    return 'knight' if move_notation.include?('N')
    return 'rook' if move_notation.include?('R')
    'pawn'
  end

  def create_notation(position_index, new_position, upgraded_type)
    piece = pieces.find_by(position_index: position_index)
    return castle_notation(new_position) if piece.king_moved_two?(new_position)
    new_notation = PIECE_CODE[piece.piece_type.to_sym]
    new_notation += start_notation(piece, new_position) unless ['king', 'queen'].include?(piece.piece_type)
    new_notation += capture_notation(new_notation, piece, new_position)
    new_notation += new_position
    new_notation += '=' + PIECE_CODE[upgraded_type.to_sym] if upgraded_type.present?
    new_notation + '.'
  end

  def castle_notation(new_position)
    new_position[0] == 'c' ? 'O-O-O.' : 'O-O.'
  end

  def start_notation(piece, next_move)
    same_pieces = matching_pieces(piece.piece_type, piece.color, next_move)
    return '' if same_pieces.count == 1

    column_is_unique?(same_pieces, piece.position) ? piece.position[0] : piece.position[1]
  end

  def matching_pieces(piece_type, piece_color, new_position)
    pieces.where(piece_type: piece_type, color: piece_color).select do |piece|
      piece.valid_moves.include?(new_position)
    end
  end

  def capture_notation(notation, piece, new_position)
    if pieces.where(position: new_position).present?
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
