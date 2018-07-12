class Piece
  include MoveLogic

  attr_accessor :game_id, :piece_type, :color, :position, :position_index,
    :moved_two, :has_moved, :enemy_targets

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

  def valid_moves
    @valid_moves ||= moves_for_piece.select { |move| valid_move?(move) }
  end

  def valid_move?(move)
    [
      valid_move_path?(move, game.pieces.map(&:position)),
      valid_destination?(move, game.pieces),
      valid_for_piece?(move, game.pieces),
      king_is_safe?(color, game.pieces_with_next_move(position_index.to_s + move))
    ].all?
  end

  def game
    @game ||= Game.find(game_id)
  end
end
