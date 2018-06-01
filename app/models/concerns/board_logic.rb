module BoardLogic
  extend ActiveSupport::Concern

  def update_notation(position_index, new_position, upgraded_type)
    new_notation = create_notation(position_index, new_position, upgraded_type)

    update(notation: (notation.to_s + new_notation.to_s))
  end

  def update_game(piece, new_position, upgraded_type = '')
    update_piece(piece, new_position, upgraded_type)
    update_board(piece)
  end

  def update_piece(piece, new_position, upgraded_type)
    handle_castle(piece, new_position) if piece.king_moved_two?(new_position)
    handle_en_passant(piece, new_position) if en_passant?(piece, new_position)
    pieces.where(position: new_position).destroy_all
    piece.update(
      position: new_position,
      has_moved: true,
      moved_two: piece.pawn_moved_two?(new_position),
      piece_type: (upgraded_type.present? ? upgraded_type : piece.piece_type)
    )
  end

  def update_board(piece)
    game_move = create_move(piece)
    game_move.setup = Setup.find_or_create_by(position_signature: create_signature(pieces))
    game_move.save
  end

  def create_move(piece)
    moves.create(
      value: (piece.position_index.to_s + piece.position),
      move_count: (moves.count + 1)
    )
  end

  def create_signature(game_pieces)
    game_pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.')
  end

  def handle_castle(piece, new_position)
    column_difference = piece.position[0].ord - new_position[0].ord
    row = piece.color == 'white' ? '1' : '8'

    if column_difference == -2
      pieces.find_by(position: ('h' + row)).update(position: ('f' + row))
    end

    if column_difference == 2
      pieces.find_by(position: ('a' + row)).update(position: ('d' + row))
    end
  end

  def handle_en_passant(piece, new_position)
    captured_position = new_position[0] + piece.position[1]
    captured_piece = pieces.find_by(position: captured_position).destroy
  end

  def en_passant?(piece, position)
    [
      piece.piece_type == 'pawn',
      piece.position[0] != position[0],
      pieces.find_by(position: position).blank?
    ].all?
  end

  def checkmate?(game_pieces, turn)
    no_valid_moves?(game_pieces, turn) &&
      !pieces.find_by(color: turn)
             .king_is_safe?(turn, game_pieces)
  end

  def stalemate?(game_pieces, turn)
    king = pieces.find_by(color: current_turn)
    [
      no_valid_moves?(game_pieces, turn) && king.king_is_safe?(current_turn, game_pieces),
      insufficient_pieces?,
      three_fold_repitition?
    ].any?
  end

  def insufficient_pieces?
    black_pieces = pieces.where(color: 'black').pluck(:piece_type)
    white_pieces = pieces.where(color: 'white').pluck(:piece_type)
    piece_types = ['queen', 'pawn', 'rook']

    [black_pieces, white_pieces].all? do |pieces_left|
      pieces_left.count < 3 &&
        pieces_left.none? { |piece| piece_types.include?(piece) }
    end
  end

  def three_fold_repitition?
    moves.count > 9 && moves.last(8).map(&:value).uniq.count < 5
  end

  def no_valid_moves?(game_pieces, turn)
    game_pieces.select { |piece| piece.color == turn }.all? do |piece|
      piece.valid_moves.blank?
    end
  end
end
