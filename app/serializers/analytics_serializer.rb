class AnalyticsSerializer
  class << self
    def serialize(moves)
      {
        data: {
          type: 'analytics',
          attributes: { moves: moves }
        }
      }.to_json
    end
  end
end
