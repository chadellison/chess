class AnalyticsSerializer
  class << self
    def serialize(moves, turn)
      {
        data: {
          type: 'analytics',
          attributes: {
            moves: moves,
            turn: turn
          }
        }
      }.to_json
    end
  end
end
