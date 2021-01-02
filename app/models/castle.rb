class Castle
  def self.create_abstraction(fen_notation, turn)
    castle_string = fen_notation.split[2]
    if castle_string == '-'
      0
    else
      value = castle_string.chars.reduce(0) do |sum, char|
        if char == char.upcase
          sum + 1
        else
          sum - 1
        end
      end
      turn == 'w' ? -value : value
    end
  end
end
