class PieceSerializer
  class << self
    def serialize(piece)
      {
        position: piece.position,
        positionIndex: piece.position_index,
        color: piece.color,
        pieceType: piece.piece_type,
        movedTwo: piece.moved_two,
        hasMoved: piece.has_moved
      }
    end
  end
end
