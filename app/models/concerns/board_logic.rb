module BoardLogic
  extend ActiveSupport::Concern

  def update_notation(position_index, new_position, upgraded_type)
    new_notation = create_notation(position_index, new_position, upgraded_type)

    update(notation: (notation.to_s + new_notation.to_s))
  end

  def update_game(position_index, new_position, upgraded_type = '')
    move_key = notation.split('.')[0..(moves.count)].join('.')

    if in_cache?(move_key)
      update_game_from_cache(move_key)
    else
      piece = find_piece_by_index(position_index)
      updated_piece = update_piece(piece, new_position, upgraded_type)
      update_board(piece, updated_piece)
    end
  end

  def update_piece(piece, new_position, upgraded_type)
    Piece.new(
      position_index: piece.position_index,
      position: new_position,
      has_moved: true,
      piece_type: (upgraded_type.present? ? upgraded_type : piece.piece_type)
    )
  end

  def update_board(piece, updated_piece)
    new_pieces = Game.pieces_with_next_move(pieces, updated_piece.position_index.to_s + updated_piece.position)
    update_pieces(new_pieces)
    game_move = new_move(updated_piece)

    game_move.setup = Setup.create_setup(new_pieces, opponent_color[0])
    add_to_cache(notation.split('.')[0..(moves.count)].join('.'), game_move)
    moves << game_move
    game_move.save
  end

  def new_move(piece)
    promoted_pawn = promoted_pawn?(piece) ? piece.piece_type : nil
    Move.new(
      value: (piece.position_index.to_s + piece.position),
      move_count: (moves.count + 1),
      promoted_pawn: promoted_pawn
    )
  end

  def promoted_pawn?(piece)
    (9..24).include?(piece.position_index) && piece.piece_type != 'pawn'
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
      piece.valid_moves(game_pieces).blank?
    end
  end
end
