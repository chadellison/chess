class GameMoveLogic
  include CacheLogic

  def pgn_logic
    @pgn_logic ||= PgnLogic.new
  end

  def notation_logic
    @notation_logic ||= Notation.new
  end

  def find_next_moves(pieces, turn, notation)
    fen_data = pgn_logic.convert_to_fen(notation)
    key = 'next_moves_' + fen_data.board_string + fen_data.active

    if in_cache?(key)
      JSON.parse(get_from_cache(key)).map { |move| MoveSerializer.deserialize(move) }
    else
      next_moves = pieces.select { |piece| piece.color == turn }.map do |piece|
        all_next_moves_for_piece(piece, pieces, notation)
      end.flatten
      add_to_cache(key, next_moves.map { |move| MoveSerializer.serialize(move) })
      next_moves
    end
  end

  def all_next_moves_for_piece(piece, pieces, notation)
    piece.valid_moves.map do |move|
      upgraded_type = piece.piece_type == 'pawn' && ['1', '8'].include?(move[1]) ? 'queen' : ''
      new_notation = notation_logic.create_notation(
        piece.position_index,
        move,
        upgraded_type,
        pieces
      )

      updated_notation = (notation.to_s.split('.') << new_notation)
      fen_data = pgn_logic.convert_to_fen(updated_notation.join('.'))
      move_value = piece.position_index.to_s + move
      game_move = Move.new(value: move_value, move_count: updated_notation.size + 1)

      setup = Setup.find_setup(fen_data)
      game_move.setup = setup
      game_move
    end
  end

  def pieces_with_next_move(game_pieces, move)
    castle = false
    en_passant = false
    piece_index = move.to_i
    updated_pieces = game_pieces.reject { |piece| piece.position == move[-2..-1] }
      .map do |piece|
        cloned_piece = piece.clone

        if piece.position_index == piece_index
          castle = cloned_piece.king_moved_two?(move[-2..-1])
          en_passant = en_passant?(piece, move[-2..-1], game_pieces)
          update_piece(piece, cloned_piece, move)
        end

        cloned_piece
      end
    updated_pieces = update_rook(move, updated_pieces) if castle
    updated_pieces = handle_en_passant(move, updated_pieces) if en_passant
    updated_pieces
  end

  def refresh_board(game_pieces, move)
    pieces = pieces_with_next_move(game_pieces, move)
    load_move_attributes(pieces)
    pieces
  end

  def load_move_attributes(game_pieces)
    game_pieces.each do |piece|
      piece.enemy_targets = []
      piece.valid_moves = []
      piece.moves_for_piece.each do |move|
        if piece.valid_move?(game_pieces, move)
          piece.valid_moves.push(move)
          load_enemy_target(move, game_pieces, piece)
        end
      end
    end
  end

  def load_enemy_target(move, game_pieces, piece)
    destination_piece = game_pieces.detect { |piece| piece.position == move }
    if destination_piece.present?
      piece.enemy_targets.push(destination_piece.position_index)
    end
  end

  def en_passant?(piece, position, game_pieces)
    [
      piece.piece_type == 'pawn',
      piece.position[0] != position[0],
      game_pieces.detect { |p| p.position == position }.blank?
    ].all?
  end

  def should_promote_pawn?(move_value)
    (9..24).include?(move_value.to_i) &&
      (move_value[-1] == '8' || move_value[-1] == '1')
  end

  def update_rook(king_move, game_pieces)
    new_rook_column = king_move[-2] == 'g' ? 'f' : 'd'
    new_rook_row = king_move[-1] == '1' ? '1' : '8'
    new_rook_position = new_rook_column + new_rook_row
    positions_with_indices = { d8: 1, f8: 8, d1: 25, f1: 32 }
    rook_index = positions_with_indices[new_rook_position.to_sym]

    game_pieces.map do |game_piece|
      if game_piece.position_index == rook_index
        game_piece.position = new_rook_position
      end
      game_piece
    end
  end

  def handle_en_passant(pawn_move_value, pieces)
    captured_row = pawn_move_value[-1] == '6' ? '5' : '3'
    pieces.reject do |game_piece|
      game_piece.position == pawn_move_value[-2] + captured_row
    end
  end

  def update_piece(initial_piece, new_piece, move)
    new_piece.moved_two = new_piece.piece_type == 'pawn' && new_piece.forward_two?(move[-2..-1])
    new_piece.piece_type = 'queen' if should_promote_pawn?(move)
    new_piece.position = move[-2..-1]
    new_piece.has_moved = true
  end
end
