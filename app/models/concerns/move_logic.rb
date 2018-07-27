module MoveLogic
  extend ActiveSupport::Concern

  def moves_for_rook
    moves_up + moves_down + moves_left + moves_right
  end

  def moves_for_bishop
    top_right = extract_diagonals(moves_right.zip(moves_up))
    top_left = extract_diagonals(moves_left.zip(moves_up))
    bottom_left = extract_diagonals(moves_left.zip(moves_down))
    bottom_right = extract_diagonals(moves_right.zip(moves_down))

    top_right + top_left + bottom_left + bottom_right
  end

  def moves_for_queen
    moves_for_rook + moves_for_bishop
  end

  def moves_for_king
    king_moves = moves_for_queen.reject do |move|
      move[0] > position[0].next ||
        move[0] < (position[0].ord - 1).chr ||
        move[1].to_i > position[1].to_i + 1 ||
        move[1].to_i < position[1].to_i - 1
    end

    castle_moves = [(position[0].ord - 2).chr + position[1], position[0].next.next + position[1]]
    king_moves + castle_moves
  end

  def moves_for_knight
    moves = []
    column = position[0].ord
    row = position[1].to_i

    moves << (column - 2).chr + (row + 1).to_s
    moves << (column - 2).chr + (row - 1).to_s

    moves << (column + 2).chr + (row + 1).to_s
    moves << (column + 2).chr + (row - 1).to_s

    moves << (column - 1).chr + (row + 2).to_s
    moves << (column - 1).chr + (row - 2).to_s

    moves << (column + 1).chr + (row + 2).to_s
    moves << (column + 1).chr + (row - 2).to_s

    remove_out_of_bounds_moves(moves)
  end

  def moves_for_pawn
    left_letter = (position[0].ord - 1).chr
    right_letter = (position[0].ord + 1).chr
    up_count = position[1].to_i + 1
    down_count = position[1].to_i - 1

    one_forward = color == 'white' ? up_count : down_count
    two_forward = color == 'white' ? up_count + 1 : (down_count - 1).abs

    possible_moves = [
      position[0] + one_forward.to_s,
      position[0] + two_forward.to_s,
      left_letter[0] + one_forward.to_s,
      right_letter[0] + one_forward.to_s
    ]

    remove_out_of_bounds_moves(possible_moves)
  end

  def remove_out_of_bounds_moves(moves)
    moves.reject do |move|
      move[0] < 'a' ||
        move[0] > 'h' ||
        move[1..-1].to_i < 1 ||
        move[1..-1].to_i > 8
    end
  end

  def extract_diagonals(moves)
    moves.map do |move_pair|
      (move_pair[0][0] + move_pair[1][1]) unless move_pair.include?(nil)
    end.compact
  end

  def moves_up(count = 8)
    possible_moves = []
    row = position[1].to_i

    while row < count
      row += 1
      possible_moves << (position[0] + row.to_s)
    end
    possible_moves
  end

  def moves_down(count = 1)
    possible_moves = []
    row = position[1].to_i

    while row > count
      row -= 1
      possible_moves << (position[0] + row.to_s)
    end
    possible_moves
  end

  def moves_left(letter = 'a')
    possible_moves = []
    column = position[0]

    while column > letter
      column = (column.ord - 1).chr

      possible_moves << (column + position[1])
    end
    possible_moves
  end

  def moves_right(letter = 'h')
    possible_moves = []
    column = position[0]

    while column < letter
      column = column.next

      possible_moves << (column + position[1])
    end
    possible_moves
  end

  def valid_move_path?(destination, occupied_spaces)
    if piece_type == 'knight'
      true
    elsif position[0] == destination[0]
      !vertical_collision?(destination, occupied_spaces)
    elsif position[1] == destination[1]
      !horizontal_collision?(destination, occupied_spaces)
    else
      !diagonal_collision?(destination, occupied_spaces)
    end
  end

  def valid_destination?(destination, game_pieces)
    destination_piece = game_pieces.detect { |piece| piece.position == destination }
    destination_piece.blank? || destination_piece.color == opposite_color
  end

  def find_piece_code
   code = { king: 'k', queen: 'q', rook: 'r', bishop: 'b', knight: 'n', pawn: 'p' }
      piece_code = code[piece_type.to_sym]
      color == 'white' ? piece_code.capitalize : piece_code
  end

  def vertical_collision?(destination, occupied_spaces)
    row = position[1].to_i
    difference = (row - destination[1].to_i).abs - 1

    if row > destination[1].to_i
      (moves_down((difference - row).abs) & occupied_spaces).present?
    else
      (moves_up(difference + row) & occupied_spaces).present?
    end
  end

  def horizontal_collision?(destination, occupied_spaces)
    if position[0] > destination[0]
      (moves_left((destination[0].ord + 1).chr) & occupied_spaces).present?
    else
      (moves_right((destination[0].ord - 1).chr) & occupied_spaces).present?
    end
  end

  def diagonal_collision?(destination, occupied_spaces)
    if position[0] < destination[0]
      horizontal_moves = moves_right((destination[0].ord - 1).chr)
    else
      horizontal_moves = moves_left((destination[0].ord + 1).chr)
    end

    difference = (position[1].to_i - destination[1].to_i).abs - 1
    if position[1] < destination[1]
      vertical_moves = moves_up(difference + position[1].to_i)
    else
      vertical_moves = moves_down((difference - position[1].to_i).abs)
    end
    (extract_diagonals(horizontal_moves.zip(vertical_moves)) & occupied_spaces)
      .present?
  end

  def king_is_safe?(allied_color, game_pieces)
    king = game_pieces.detect do |piece|
      piece.piece_type == 'king' && piece.color == allied_color
    end

    return false if king.nil? || kings_too_close?(game_pieces)

    occupied_spaces = game_pieces.map(&:position)
    opponent_pieces = game_pieces.reject do |piece|
      piece.color == allied_color || piece.piece_type == 'king'
    end

    opponent_pieces.none? do |piece|
      piece.moves_for_piece.include?(king.position) &&
        piece.valid_move_path?(king.position, occupied_spaces) &&
        piece.valid_destination?(king.position, game_pieces) &&
        piece.valid_for_piece?(king.position, game_pieces)
    end
  end

  def kings_too_close?(game_pieces)
    positions = game_pieces.select { |piece| piece.piece_type == 'king' }
                       .map(&:position)

    [
      (positions.first[0].ord - positions.last[0].ord).abs,
      (positions.first[1].to_i - positions.last[1].to_i).abs
    ].all? { |value| value < 2 }
  end

  def valid_for_piece?(next_move, game_pieces)
    return castle?(next_move, game_pieces) if king_moved_two?(next_move)
    return valid_for_pawn?(next_move, game_pieces) if piece_type == 'pawn'
    true
  end

  def king_moved_two?(next_move)
    piece_type == 'king' && (position[0].ord - next_move[0].ord).abs == 2
  end

  def castle?(next_move, game_pieces)
    column = next_move[0] == 'c' ? 'a' : 'h'
    rook = game_pieces.detect { |piece| piece.position == (column + next_move[1]) }

    if next_move[0] == 'c'
      through_check_moves = game.pieces_with_next_move(game.pieces, "#{position_index}d#{next_move[1]}")
    else
      through_check_moves = game.pieces_with_next_move(game.pieces, "#{position_index}f#{next_move[1]}")
    end

    [
      rook.present? && rook.has_moved.blank?, has_moved.blank?,
      king_is_safe?(color, game.pieces),
      king_is_safe?(color, through_check_moves)
    ].all?
  end

  def valid_for_pawn?(next_move, game_pieces)
    if next_move[0] == position[0]
      advance_pawn?(next_move, game_pieces)
    else
      capture?(next_move, game_pieces)
    end
  end

  def capture?(next_move, game_pieces)
    [
      next_move[0].ord == position[0].ord + 1 || next_move[0].ord == position[0].ord - 1,
      next_move == next_move[0] + advance_pawn_row(1),
      !empty_square?(next_move, game_pieces) || can_en_pessant?(next_move, game_pieces)
    ].all?
  end

  def can_en_pessant?(next_move, game_pieces)
    game_pieces.select do |piece|
      piece.position == (next_move[0] + position[1]) &&
      piece.moved_two &&
      piece.color == opposite_color
    end.present?
  end

  def opposite_color
    color == 'white' ? 'black' : 'white'
  end

  def empty_square?(space, game_pieces)
    game_pieces.none? { |piece| piece.position == space }
  end

  def move_two?(next_move, game_pieces)
    [
      empty_square?(next_move[0] + advance_pawn_row(1), game_pieces),
      empty_square?(next_move[0] + advance_pawn_row(2), game_pieces),
      has_moved.blank?
    ].all?
  end

  def advance_pawn_row(amount)
    if color == 'white'
      (position[1].to_i + amount).to_s
    else
      (position[1].to_i - amount).to_s
    end
  end

  def advance_pawn?(next_move, game_pieces)
    if forward_two?(next_move)
      move_two?(next_move, game_pieces)
    else
      advance_pawn_row(1) == next_move[1] && empty_square?(next_move, game_pieces)
    end
  end

  def forward_two?(next_move)
    (next_move[1].to_i - position[1].to_i).abs == 2
  end
end
