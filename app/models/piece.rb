class Piece < ApplicationRecord
  belongs_to :game, optional: true

  include MoveLogic

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
    moves_for_piece.select { |move| valid_move?(move) }
  end

  def valid_move?(move)
    [
      valid_move_path?(move, game.pieces.map(&:position)),
      valid_destination?(move, game.reload.pieces),
      valid_for_piece?(move, game.reload.pieces),
      king_is_safe?(color, game.pieces_with_next_move(position_index.to_s + move))
    ].all?
  end
end
