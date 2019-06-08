class DefendedLogic
  def self.create_signature(game_data)
    pieces = game_data[:pieces]

    pieces.reduce(0) do |sum, piece|
      if Piece.defenders(piece.position_index, pieces).present?
        if piece.color == 'white'
          sum + 1
        else
          sum - 1
        end
      else
        sum
      end
    end
  end
end
