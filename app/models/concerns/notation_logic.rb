module NotationLogic
  extend ActiveSupport::Concern

  PIECE_CODE = {
    king: 'K', queen: 'Q', bishop: 'B', knight: 'N', rook: 'R', pawn: ''
  }

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
    same_pieces = matching_pieces(piece, next_move)
    return '' if same_pieces.count == 1

    index_is_unique?(same_pieces, piece) ? piece.position[0] : piece.position[1]
  end

  def matching_pieces(piece, new_position)
    pieces.where(piece_type: piece.piece_type, color: piece.color).select do |game_piece|
        game_piece.moves_for_piece.include?(new_position) &&
          game_piece.valid_move?(new_position)
    end
  end

  def capture_notation(notation, piece, new_position)
    if pieces.where(position: new_position).present?
      notation.blank? ? piece.position[0] + 'x' : 'x'
    else
      ''
    end
  end

  def index_is_unique?(same_pieces, piece)
    same_pieces.select do |game_piece|
      game_piece.position[0] == piece.position[0]
    end.count == 1
  end
end
