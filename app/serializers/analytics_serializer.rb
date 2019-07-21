class AnalyticsSerializer
  class << self
    def serialize(attributes)
      {
        data: {
          type: 'analytics',
          attributes: attributes
        }
      }.to_json
    end
  end
end
