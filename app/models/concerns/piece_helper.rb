module PieceHelper
  extend ActiveSupport::Concern

  PIECE_CLASS = {
    pawn: Pawn, knight: Knight, bishop: Bishop, rook: Rook, queen: Queen, king: King
  }

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))
                      .map(&:symbolize_keys)

    json_pieces.map do |json_piece|
      piece_class = PIECE_CLASS[json_piece.keys.first]
      piece = piece_class.new(json_piece[json_piece.keys.first].symbolize_keys)

      piece.game_id = id
      piece
    end
  end

  def pieces
    if moves.present?
      @pieces ||= reload_pieces
    else
      @pieces ||= add_pieces
    end
  end

  def reload_pieces
    last_move = moves.order(:move_count).last
    move_indices = moves.map { |move| position_index_from_move(move.value) }
    pawn_moved_two = pawn_moved_two?

    @pieces = last_move.setup.position_signature.split('.').map do |piece_value|
      position_index = position_index_from_move(piece_value)
      piece_class = piece_class_from_index(position_index)
      piece_class.new({
        game_id: id,
        position: piece_value[-2..-1],
        position_index: position_index,
        color: color_from_position_index(position_index),
        has_moved: move_indices.include?(position_index),
        moved_two: pawn_moved_two
      })
    end
  end

  def piece_class_from_index(index)
    promoted = moves.detect do |move|
      position_index_from_move(move.value) == index && move.promoted_pawn.present?
    end

    return promoted.promoted_pawn.to_sym[PIECE_CLASS] if promoted.present?
    return Pawn if (9..24).include?(index)
    return Knight if [2, 7, 26, 31].include?(index)
    return Bishop if [3, 6, 27, 30].include?(index)
    return Rook if [1, 8, 25, 32].include?(index)
    return Queen if [4, 28].include?(index)
    return King if [5, 29].include?(index)
  end

  def update_pieces(pieces)
    @pieces = pieces
  end

  def color_from_position_index(position_index)
    position_index < 17 ? 'black' : 'white'
  end

  def find_piece_by_position(position)
    pieces.detect { |piece| piece.position == position }
  end

  def find_piece_by_index(index)
    pieces.detect { |piece| piece.position_index == index }
  end

  def last_move_index(last_move)
    position_index_from_move(last_move.value).to_i
  end

  def pawn_moved_two?
    ordered_moves = moves.order(:move_count)
    last_move = ordered_moves.last
    last_moved_piece_type = piece_class_from_index(last_move_index(last_move))
    return false unless last_moved_piece_type.is_a? Pawn

    if moves.count == 1
      ['4', '5'].include?(last_move.value[-1])
      true
    else
      previous_position = ordered_moves[-2].setup.position_signature.split('.').detect do |value|
        position_index_from_move(value) == last_move_index(last_move)
      end[-2..-1]

      (previous_position[1].to_i - last_move.value[-1].to_i).abs == 2
    end
  end
end
