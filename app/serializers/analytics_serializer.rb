class AnalyticsSerializer
  class << self
    def serialize(attributes)
      {
        data: {
          type: 'analytics',
          attributes: attributes
        }
      }
    end
  end
end
