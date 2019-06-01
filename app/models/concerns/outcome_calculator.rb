module OutcomeCalculator
  extend ActiveSupport::Concern

  def outcome_ratio
    outcomes[:white_wins].to_f - outcomes[:black_wins].to_f / 2
  end

  def update_outcomes(outcome)
    key = OUTCOME_KEY[outcome]
    if outcomes[key].present?
      outcomes[key] += 1
    else
      outcomes[key] = 1
    end
    save
  end
end
