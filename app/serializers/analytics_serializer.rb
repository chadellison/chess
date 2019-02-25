class AnalyticsSerializer
  class << self
    def serialize(setup)
      setup_outcomes = {}
      setup_outcomes = setup.outcomes if setup.present?
      {
        data: {
          type: 'analytics',
          attributes: {
            whiteWins: setup_outcomes[:white_wins].to_i,
            blackWins: setup_outcomes[:black_wins].to_i,
            draws: setup_outcomes[:draws].to_i
          }
        }
      }
    end
  end
end
