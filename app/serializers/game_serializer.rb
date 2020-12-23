class GameSerializer
  class << self
    def serialize(game, board, notation)
      {
        id: game.id ? game.id : 'default',
        board: JSON.parse(board.to_json),
        notation: notation
      }
    end

    # def format_outcome(outcome)
    #   case outcome
    #   when '1' then 'White wins!'
    #   when '-1' then 'Black wins!'
    #   when '0' then 'Draw'
    #   end
    # end
  end
end
