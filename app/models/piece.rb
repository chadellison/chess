class Piece
  include MoveLogic
  include PieceLogic

  attr_accessor :game_id, :piece_type, :color, :position, :position_index,
    :moved_two, :has_moved, :valid_moves, :enemy_targets

  def initialize(attributes = {})
    @piece_type = attributes[:piece_type]
    @color = attributes[:color]
    @position = attributes[:position]
    @position_index = attributes[:position_index]
    @game_id = attributes[:game_id]
    @has_moved = attributes[:has_moved]
    @moved_two = attributes[:moved_two]
    @enemy_targets = []
  end

  def moves_for_piece
    case piece_type
    when 'rook'
      moves_for_rook
    when 'bishop'
      moves_for_bishop
    when 'queen'
      moves_for_queen
    when 'king'
      moves_for_king
    when 'knight'
      moves_for_knight
    when 'pawn'
      moves_for_pawn
    end
  end

  def valid_moves(game_pieces)
    @valid_moves ||= moves_for_piece.select do |move|
      if valid_move?(game_pieces, move)
        find_enemy_targets(move, game_pieces)
        true
      end
    end
  end

  def valid_move?(game_pieces, move)
    [
      valid_move_path?(move, game_pieces.map(&:position)),
      valid_destination?(move, game_pieces),
      valid_for_piece?(move, game_pieces),
      king_is_safe?(color, game.pieces_with_next_move(game_pieces, position_index.to_s + move))
    ].all?
  end

  def find_enemy_targets(move, game_pieces)
    destination_piece = game_pieces.detect { |piece| piece.position == move }
    if destination_piece.present?
      @enemy_targets.push(destination_piece.find_piece_code + move)
    end
  end

  def game
    @game ||= Game.find(game_id)
  end
end
