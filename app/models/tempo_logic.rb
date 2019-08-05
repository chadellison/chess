class TempoLogic
  def self.create_signature(setup_data)
    return 0 if setup_data.move.value.blank? || is_pawn?(setup_data.move.value[0..-3].to_i)
    move_position = setup_data.move.value[-2..-1]
    occupied_spaces = setup_data.pieces.map(&:position)
    opponent_color = setup_data.opponent_color
    ally_moves = ally_moves(setup_data.allies)

    move_set(setup_data.opponents).reduce(0) do |total, piece_set|
      possible_piece = possible_piece(move_position, piece_set.keys.first.to_s, opponent_color)

      moves_with_tempo = possible_piece.moves_for_piece.select do |move|
        has_tempo?(
          possible_piece,
          ally_moves,
          move,
          setup_data.pieces,
          occupied_spaces
        )
      end

      if setup_data.turn == 'white'
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

  def self.has_tempo?(possible_piece, ally_moves, move, pieces, occupied_spaces)
    [
      possible_piece.valid_move_path?(move, occupied_spaces),
      possible_piece.valid_destination?(move, pieces),
      !ally_moves.include?(move)
    ].all?
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
