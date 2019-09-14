module PieceHelper
  extend ActiveSupport::Concern

  def add_pieces
    game_pieces = Marshal.load(Marshal.dump(PIECES))
    game_move_logic.load_move_attributes(game_pieces)
    game_pieces
  end

  def pieces
    if moves.present?
      @pieces ||= reload_pieces
    else
      @pieces ||= add_pieces
    end
  end

  def game_move_logic
    @game_move_logic ||= GameMoveLogic.new
  end

  def reload_pieces
    move_indices = moves.map { |move| move.value.to_i }
    pawn_moved_two = pawn_moved_two?
    @pieces = last_move.setup.position_signature[0..-2].split('.').map do |piece_value|
      position_index = piece_value.to_i
      Piece.new({
        game_id: id,
        position: piece_value[-2..-1],
        position_index: position_index,
        color: color_from_position_index(position_index),
        piece_type: piece_type_from_position_index(position_index),
        has_moved: move_indices.include?(position_index),
        moved_two: pawn_moved_two
      })
    end
    game_move_logic.load_move_attributes(@pieces)
    @pieces
  end

  def update_pieces(pieces)
    @pieces = pieces
  end

  def color_from_position_index(position_index)
    position_index < 17 ? 'black' : 'white'
  end

  def piece_type_from_position_index(position_index)
    promoted = moves.detect do |move|
      move.value.to_i == position_index && move.promoted_pawn.present?
    end

    return promoted.promoted_pawn if promoted.present?
    return 'knight' if [2, 7, 26, 31].include?(position_index)
    return 'bishop' if [3, 6, 27, 30].include?(position_index)
    return 'rook' if [1, 8, 25, 32].include?(position_index)
    return 'queen' if [4, 28].include?(position_index)
    return 'king' if [5, 29].include?(position_index)
    return 'pawn'
  end

  def find_piece_by_position(position)
    pieces.detect { |piece| piece.position == position }
  end

  def find_piece_by_index(index)
    pieces.detect { |piece| piece.position_index == index }
  end

  def last_move
    moves.max_by(&:move_count)
  end

  def ordered_moves
    moves.sort_by(&:move_count)
  end

  def pawn_moved_two?
    last_moved_piece_type = piece_type_from_position_index(last_move.value.to_i)
    return false unless last_moved_piece_type == 'pawn'

    ['4', '5'].include?(last_move.value[-1]) && moves.one? do |move|
      move.value.to_i == last_move.value.to_i
    end
  end
end
