module BoardLogic
  extend ActiveSupport::Concern

  def pieces_with_next_move(game_pieces, move)
    castle = false
    en_passant = false
    piece_index = position_index_from_move(move)
    updated_pieces = game_pieces.reject { |piece| piece.position == move[-2..-1] }
      .map do |piece|
        game_piece = Piece.new(
          color: piece.color,
          piece_type: piece.piece_type,
          position_index: piece.position_index,
          game_id: piece.game_id,
          position: piece.position,
          has_moved: piece.has_moved
        )

        if piece.position_index == piece_index
          game_piece.moved_two = game_piece.piece_type == 'pawn' && game_piece.forward_two?(move[-2..-1])
          castle = game_piece.king_moved_two?(move[-2..-1])
          en_passant = en_passant?(piece, move[-2..-1])
          game_piece.piece_type = 'queen' if should_promote_pawn?(move)
          game_piece.position = move[-2..-1]
          game_piece.has_moved = true
        end

        game_piece
      end

    updated_pieces = update_rook(move, updated_pieces) if castle
    updated_pieces = handle_en_passant(move, updated_pieces) if en_passant
    updated_pieces
  end

  def should_promote_pawn?(move_value)
    (9..24).include?(position_index_from_move(move_value)) &&
      (move_value[-1] == '8' || move_value[-1] == '1')
  end

  def update_notation(position_index, new_position, upgraded_type)
    new_notation = create_notation(position_index, new_position, upgraded_type)

    update(notation: (notation.to_s + new_notation.to_s))
  end

  def update_game(piece, new_position, upgraded_type = '')
    updated_piece = update_piece(piece, new_position, upgraded_type)
    update_board(piece, updated_piece)
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
    new_pieces = pieces_with_next_move(pieces, updated_piece.position_index.to_s + updated_piece.position)
    update_pieces(new_pieces)
    game_move = new_move(updated_piece)
    game_move.setup = create_setup(new_pieces, current_turn)
    game_move.save
  end

  def create_setup(new_pieces, game_turn)
    game_signature = create_signature(new_pieces, game_turn[0])
    setup = Setup.find_or_create_by(position_signature: game_signature)
    new_pieces.each { |piece| piece.valid_moves(new_pieces) }
    setup.add_signatures(new_pieces, game_turn[0])
    setup
  end

  def new_move(piece)
    promoted_pawn = promoted_pawn?(piece) ? piece.piece_type : nil
    moves.new(
      value: (piece.position_index.to_s + piece.position),
      move_count: (moves.count + 1),
      promoted_pawn: promoted_pawn
    )
  end

  def promoted_pawn?(piece)
    (9..24).include?(piece.position_index) && piece.piece_type != 'pawn'
  end

  def create_signature(game_pieces, game_turn_code)
    game_pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.') + game_turn_code
  end

  def update_rook(king_move, game_pieces)
    new_rook_column = king_move[-2] == 'g' ? 'f' : 'd'
    new_rook_row = king_move[-1] == '1' ? '1' : '8'

    new_rook_position = new_rook_column + new_rook_row

    rook_index = case new_rook_position
    when 'd8' then 1
    when 'f8' then 8
    when 'd1' then 25
    when 'f1' then 32
    end

    game_pieces.map do |game_piece|
      if game_piece.position_index == rook_index
        game_piece.position = new_rook_position
      end
      game_piece
    end
  end

  def handle_en_passant(pawn_move_value, updated_pieces)
    captured_row = pawn_move_value[-1] == '6' ? '5' : '3'
    updated_pieces.reject do |game_piece|
      game_piece.position == pawn_move_value[-2] + captured_row
    end
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
      piece.valid_moves(game_pieces).blank?
    end
  end
end
