class AnalyticsSerializer
  class << self
    def serialize(notation)
      {
        data: {
          type: 'analytics',
          attributes: {
            whiteWins: Game.similar_games(notation).winning_games(1).machine_games.count,
            blackWins: Game.similar_games(notation).winning_games(-1).machine_games.count,
            draws: Game.similar_games(notation).winning_games([0, nil]).machine_games.count
          }
        }
      }
    end
  end
end
