module PieceHelper
  extend ActiveSupport::Concern

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))
                      .map(&:symbolize_keys)

    json_pieces.map do |json_piece|
      json_piece[:game_id] = id
      Piece.new(json_piece)
    end
  end

  def pieces
    if moves.count > 0
      @pieces ||= reload_pieces
    else
      @pieces ||= add_pieces
    end
  end

  def reload_pieces
    signature = moves.order(:move_count).last.setup.position_signature
    move_indices = moves.map { |move| position_index_from_move(move.value).to_i }
    pawn_moved_two = pawn_moved_two?
    last_move = moves.order(:move_count).last

    @pieces = signature.split('.').map do |piece_value|
      position_index = position_index_from_move(piece_value).to_i
      moved_two = (pawn_moved_two && position_index == last_move_index(last_move)) ? true : false
      Piece.new({
        game_id: id,
        position: piece_value[-2..-1],
        position_index: position_index,
        color: color_from_position_index(position_index),
        piece_type: piece_type_from_position_index(position_index),
        has_moved: move_indices.include?(position_index),
        moved_two: moved_two
      })
    end
  end

  def update_pieces(pieces)
    @pieces = pieces
  end

  def color_from_position_index(position_index)
    position_index < 17 ? 'black' : 'white'
  end

  def piece_type_from_position_index(position_index)
    promoted = moves.detect do |move|
      position_index_from_move(move.value) == position_index &&
        move.promoted_pawn.present?
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

  def last_move_index(last_move)
    position_index_from_move(last_move.value).to_i
  end

  def pawn_moved_two?
    last_move = moves.order(:move_count).last
    last_moved_piece_type = piece_type_from_position_index(last_move_index(last_move))
    return false unless last_moved_piece_type == 'pawn'

    if moves.count == 1
      ['4', '5'].include?(last_move.value[-1])
      true
    else
      previous_position = moves[-2].setup.position_signature.split('.').detect do |value|
        position_index_from_move(value).to_i == last_move_index(last_move)
      end[-2..-1]

      if previous_position[1].to_i.abs - last_move.value[-1].to_i.abs == 2
        pawn_moved_two = true
      end
    end
  end
end
