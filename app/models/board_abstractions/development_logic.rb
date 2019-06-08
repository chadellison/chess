class DevelopmentLogic
  def self.create_signature(game_data)
    game_data[:pieces].reduce(0) do |sum, piece|
      if piece.has_moved
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
