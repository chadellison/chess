class PieceSerializer
  class << self
    def serialize(piece)
      {
        position: piece.position,
        positionIndex: piece.position_index,
        color: piece.color,
        pieceType: piece.class.to_s.downcase,
        movedTwo: piece.moved_two,
        hasMoved: piece.has_moved
      }
    end
  end
end
