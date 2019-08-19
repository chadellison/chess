class TempoLogic
  def self.create_signature(game_data)
    return 0 if game_data.move.value.blank? || is_pawn?(game_data.move.value[0..-3].to_i)
    move_position = game_data.move.value[-2..-1]
    occupied_spaces = game_data.pieces.map(&:position)
    opponent_color = game_data.opponent_color
    ally_moves = ally_moves(game_data.allies)
    pieces = game_data.pieces

    move_set(game_data.opponents).reduce(0) do |total, piece_set|
      piece_type = piece_set.keys.first.to_s
      possible_piece = possible_piece(move_position, piece_type, opponent_color)

      moves_with_tempo = find_moves_with_tempo(
        possible_piece,
        ally_moves,
        pieces,
        occupied_spaces
      )

      if game_data.turn == 'white'
        total - with_tempo_count(piece_set, moves_with_tempo)
      else
        total + with_tempo_count(piece_set, moves_with_tempo)
      end
    end
  end

  def self.find_by_type(opponent_pieces, piece_type)
    opponent_pieces.select { |piece| piece.piece_type == piece_type }
  end

  def self.move_set(opponent_pieces)
    [
      pawn: find_by_type(opponent_pieces, 'pawn'),
      knight: find_by_type(opponent_pieces, 'knight'),
      bishop: find_by_type(opponent_pieces, 'bishop'),
      rook: find_by_type(opponent_pieces, 'rook'),
      queen: find_by_type(opponent_pieces, 'queen')
    ]
  end

  def self.piece_type_from_position_index(position_index)
    return 'knight' if [2, 7, 26, 31].include?(position_index)
    return 'bishop' if [3, 6, 27, 30].include?(position_index)
    return 'rook' if [1, 8, 25, 32].include?(position_index)
    return 'queen' if [4, 28].include?(position_index)
    return 'king' if [5, 29].include?(position_index)
    'pawn'
  end

  def self.is_pawn?(position_index)
    piece_type_from_position_index(position_index) == 'pawn'
  end

  def self.possible_piece(move_position, piece_type, opponent_color)
    Piece.new(
      position: move_position,
      piece_type: piece_type,
      color: opponent_color
    )
  end

  def self.find_moves_with_tempo(possible_piece, ally_moves, pieces, occupied_spaces)
    if possible_piece.piece_type == 'pawn'
      tempo_for_pawn?(possible_piece, ally_moves)
    else
      possible_piece.moves_for_piece.select do |move|
        has_tempo?(
          possible_piece,
          ally_moves,
          move,
          pieces,
          occupied_spaces
        )
      end
    end
  end

  def self.has_tempo?(possible_piece, ally_moves, move, pieces, occupied_spaces)
    [
      possible_piece.valid_move_path?(move, occupied_spaces),
      possible_piece.valid_destination?(move, pieces),
      !ally_moves.include?(move)
    ].all?
  end

  def self.tempo_for_pawn?(possible_piece, ally_moves)
    left_column = (possible_piece.position[0].ord - 1).chr
    right_column = possible_piece.position[0].next
    initial_row = possible_piece.position[-1].to_i

    if possible_piece.color == 'white'
      row = (initial_row - 1).to_s
    else
      row = (initial_row + 1).to_s
    end

    [left_column + row, right_column + row].select do |move|
      !ally_moves.include?(move)
    end
  end

  def self.with_tempo_count(piece_set, moves_with_tempo)
    valid_moves = piece_set.values.first.map(&:valid_moves).flatten
    valid_moves.count { |move| moves_with_tempo.include?(move) }
  end

  def self.ally_moves(allies)
    allies.map do |piece|
      if piece.piece_type == 'pawn'
        row = piece.advance_pawn_row(1)
        left_one = (piece.position[0].ord - 1).chr
        right_one = piece.position[0].next

        [left_one + row, right_one + row]
      else
        piece.valid_moves
      end
    end.flatten
  end
end
