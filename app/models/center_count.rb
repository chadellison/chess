class CenterCount
  SQUARES = {
    'c6' => true,
    'd6' => true,
    'e6' => true,
    'f6' => true,
    'c5' => true,
    'd5' => true,
    'e5' => true,
    'f5' => true,
    'c4' => true,
    'd4' => true,
    'e4' => true,
    'f4' => true,
    'c3' => true,
    'd3' => true,
    'e3' => true,
    'f3' => true,
  }

  def self.create_abstraction(pieces, next_pieces)
    value = 0
    pieces.each do |piece|
      piece.valid_moves.each do |move|
        if SQUARES[move]
          value -= 1
        end
      end
    end

    next_pieces.each do |piece|
      piece.valid_moves.each do |move|
        if SQUARES[move]
          value += 1
        end
      end
    end

    value * 0.1
  end
end
