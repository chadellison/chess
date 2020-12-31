class Development
  STARTING_SQUARES = {
    'R' => ['a1', 'h1'],
    'N' => ['b1', 'g1'],
    'B' => ['c1', 'f1'],
    'Q' => ['d1'],
    'r' => ['a8', 'h8'],
    'n' => ['b8', 'g8'],
    'b' => ['c8', 'f8'],
    'q' => ['d8']
  }

  def self.create_abstraction(all_pieces, turn)
    piece_types = ['r', 'n', 'b', 'q']
    developed = 0

    all_pieces.each do |piece|
      if piece_types.include?(piece.piece_type.downcase)
        if !STARTING_SQUARES[piece.piece_type].include?(piece.position)
          if piece.color == turn
            developed -= 1
          else
            developed += 1
          end
        end
      end
    end
    developed * 0.1
  end
end
