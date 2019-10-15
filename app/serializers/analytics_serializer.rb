class AnalyticsSerializer
  class << self
    def serialize(moves, outcomes)
      {
        data: {
          type: 'analytics',
          attributes: {
            outcomes: {
              white_wins: outcomes[:white_wins].to_i,
              black_wins: outcomes[:black_wins].to_i,
              draws: outcomes[:draws].to_i,
            },
            moves: moves
          }
        }
      }.to_json
    end
  end
end
