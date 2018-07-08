module BoardLogic
  extend ActiveSupport::Concern

  def pieces_with_next_move(move)
    pieces.reject { |piece| piece.position == move[-2..-1] }
          .map do |piece|
            if piece.position_index == move[0..-3].to_i
              piece = Piece.new({
                color: piece.color,
                piece_type: piece.piece_type,
                position_index: piece.position_index,
                game_id: piece.game_id,
                position: move[-2..-1],
                moved_two: piece.moved_two,
                has_moved: piece.has_moved
              })
            end
            piece
          end
  end

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
    pieces.reject! { |piece| piece.position == new_position }

    piece.position = new_position
    piece.has_moved = true
    piece.moved_two = piece.pawn_moved_two?(new_position)
    piece.piece_type = (upgraded_type.present? ? upgraded_type : piece.piece_type)
  end

  def update_board(piece)
    game_move = new_move(piece)
    game_move.setup = Setup.find_or_create_by(position_signature: create_signature(pieces_with_next_move(game_move.value)))
    game_move.save
  end

  def new_move(piece)
    moves.new(
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
      pieces.detect { |piece| piece.position == ('h' + row) }.position = ('f' + row)
    end

    if column_difference == 2
      pieces.detect { |piece| piece.position == ('a' + row) }.position = ('d' + row)
    end
  end

  def handle_en_passant(piece, new_position)
    captured_position = new_position[0] + piece.position[1]
    pieces.reject! { |piece| piece.position == captured_position}
  end

  def en_passant?(piece, position)
    [
      piece.piece_type == 'pawn',
      piece.position[0] != position[0],
      pieces.detect { |piece| piece.position == position }.blank?
    ].all?
  end

  def checkmate?(game_pieces, turn)
    no_valid_moves?(game_pieces, turn) &&
      !pieces.detect { |piece| piece.color == turn }.king_is_safe?(turn, game_pieces)
  end

  def stalemate?(game_pieces, turn)
    king = pieces.detect { |piece| piece.color == current_turn }
    [
      no_valid_moves?(game_pieces, turn) && king.king_is_safe?(current_turn, game_pieces),
      insufficient_pieces?,
      three_fold_repitition?
    ].any?
  end

  def insufficient_pieces?
    black_pieces = pieces.select { |piece| piece.color == 'black' }.map(&:piece_type)
    white_pieces = pieces.select { |piece| piece.color == 'white' }.map(&:piece_type)
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
