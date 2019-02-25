class AnalyticsSerializer
  class << self
    def serialize(signature)
      setup = Setup.find_by(position_signature: signature)
      if setup.present?
        white_wins = setup.outcomes.count { |outcome| outcome == 1 }
        black_wins = setup.outcomes.count { |outcome| outcome == -1 }
        draws = setup.outcomes.count { |outcome| outcome == 0 }
      else
        white_wins = 0
        black_wins = 0
        draws = 0
      end

      {
        data: {
          type: 'analytics',
          attributes: {
            whiteWins: white_wins,
            blackWins: black_wins,
            draws: draws
          }
        }
      }
    end
  end
end
