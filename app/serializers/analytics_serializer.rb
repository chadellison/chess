class AnalyticsSerializer
  class << self
    def serialize(analytics)
      {
        data: {
          type: 'analytics',
          attributes: {
            whiteWins: analytics.white_wins,
            blackWins: analytics.black_wins,
            draws: analytics.draws
          }
        }
      }
    end
  end
end
