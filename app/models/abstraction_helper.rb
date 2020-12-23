class AbstractionHelper
  VALUE_KEY = { 'p' => 1, 'n' => 2.5, 'b' => 3, 'r' => 5, 'q' => 9, 'k' => 0 }

  def self.find_material_value(pieces)
    pieces.reduce(0) do |sum, piece|
      piece_value = find_piece_value(piece)
      if piece.color == 'w'
        sum + piece_value
      else
        sum - piece_value
      end
    end
  end

  def self.find_piece_value(piece)
    VALUE_KEY[piece.piece_type.downcase]
  end

  def self.next_turn_fen(fen_notation)
    split_fen = fen_notation.split
    if split_fen[1] == 'w'
      split_fen[1] = 'b'
    else
      split_fen[1] = 'w'
    end
    split_fen[3] = '-'
    split_fen.join(' ')
  end

  def self.max_target_value(pieces)
    max = 0
    pieces.each do |piece|
      max = max_value(piece.targets, max)
    end
    max
  end

  def self.max_value(targets, max)
    targets.each do |target|
      value = find_piece_value(target)
      max = value if value > max
    end
    max
  end

  def self.next_pieces(fen_notation)
    next_fen = next_turn_fen(fen_notation)
    ChessValidator::Engine.find_next_moves(next_fen)
  end

  def self.pawn_attack(pawn)
    column = pawn.position[0]
    row = pawn.position[1]
    left_column = (column.ord - 1).chr
    right_column = column.next
    up_row = row.next
    down_row = (row.ord - 1).chr

    if pawn.color == 'w'
      [left_column + up_row, right_column + up_row]
    else
      [left_column + down_row, right_column + down_row]
    end
  end
end
