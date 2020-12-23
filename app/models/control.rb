class Control
  def self.create_signature(pieces)
    squares = {}
    pieces.each do |piece|
      piece.valid_moves.each do |move|
        if squares[move].present?
          squares[move] += 1
        else
          squares[move] = 1
        end
      end
    end

    signature = ''
    squares.each do |move, count|
      signature += move + count.to_s
    end
    signature
  end
end
