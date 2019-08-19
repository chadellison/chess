module OutcomeCalculator
  extend ActiveSupport::Concern

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
