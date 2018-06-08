class AnalyticsSerializer
  class << self
    def serialize(notation)
      {
        data: {
          type: 'analytics',
          attributes: {
            whiteWins: Game.similar_games(notation).winning_games(1).count,
            blackWins: Game.similar_games(notation).winning_games(-1).count,
            draws: Game.similar_games(notation).winning_games([0, nil]).count
          }
        }
      }
    end
  end
end
