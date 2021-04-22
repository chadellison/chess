class PositionData
  VALUE_KEY = { 'p' => 1, 'n' => 2.5, 'b' => 3, 'r' => 5, 'q' => 9, 'k' => 0 }

  attr_reader :fen_notation, :engine, :pieces, :all_pieces, :next_pieces, :next_fen,
    :turn, :target_positions, :max_target_value

  def initialize(fen_notation)
    @fen_notation = fen_notation
    @engine = ChessValidator::Engine
    @pieces = @engine.find_next_moves(fen_notation)
    @all_pieces = @engine.pieces(fen_notation)
    @next_pieces = find_next_pieces(fen_notation)
    @next_fen = next_turn_fen(fen_notation)
    @turn = fen_notation.split[1]
    @target_positions = find_target_positions(@pieces)
    @max_target_value = find_max_target_value(@pieces)
  end

  def find_piece_value(piece)
    VALUE_KEY[piece.piece_type.downcase]
  end

  def find_max_target_value(pieces)
    max = 0
    pieces.each do |piece|
      max = max_value(piece.targets, max)
    end
    max
  end

  def find_next_pieces(fen_notation)
    next_fen = next_turn_fen(fen_notation)
    engine.find_next_moves(next_fen)
  end

  def max_value(targets, max)
    targets.each do |target|
      value = find_piece_value(target)
      max = value if value > max
    end
    max
  end

  def spaces_near_king(position)
    ChessValidator::MoveLogic.spaces_near_king(position)
  end

  def find_material_value(pieces)
    pieces.reduce(0) do |sum, piece|
      piece_value = find_piece_value(piece)
      if piece.color == 'w'
        sum + piece_value
      else
        sum - piece_value
      end
    end
  end

  def next_turn_fen(fen_notation)
    split_fen = fen_notation.split
    if split_fen[1] == 'w'
      split_fen[1] = 'b'
    else
      split_fen[1] = 'w'
    end
    split_fen[3] = '-'
    split_fen.join(' ')
  end

  def pawn_attack(pawn)
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

  def find_target_positions(pieces)
    pieces.reduce([]) do |accumulator, piece|
      accumulator + piece.targets.map(&:position)
    end.uniq
  end
end
