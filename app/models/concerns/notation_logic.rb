module NotationLogic
  extend ActiveSupport::Concern

  PIECE_CODE = {
    king: 'K', queen: 'Q', bishop: 'B', knight: 'N', rook: 'R', pawn: ''
  }

  def create_notation(position_index, new_position, upgraded_type)
    piece = pieces.find_by(position_index: position_index)

    return castle_notation if piece.king_moved_two?(new_position)
    new_notation = PIECE_CODE[piece.piece_type.to_sym]
    new_notation += start_notation(piece, new_position) if ['rook', 'knight', 'bishop', 'pawn'].include?(piece.piece_type)
    new_notation += 'x' if pieces.where(position: new_position).present?
    new_notation += new_position
    new_notation += '=' + PIECE_CODE(upgraded_type.to_sym) if upgraded_type.present?
    new_notation + '.'
  end

  def castle_notation(new_position)
    new_position[0] == 'c' ? 'O-O-O.' : 'O-O.'
  end

  def start_notation(piece, new_position)
    # needs start
    ''
  end

  def piece_code(piece_type)
    {
      king: 'K', queen: 'Q', bishop: 'B', knight: 'N', rook: 'R', pawn: ''
    }[piece_type.to_sym]
  end
end
