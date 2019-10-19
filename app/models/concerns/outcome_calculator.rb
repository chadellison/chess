module OutcomeCalculator
  extend ActiveSupport::Concern

  def update_outcomes(outcome)
    key = OUTCOME_KEY[outcome]
    if outcomes[key].present?
      outcomes[key] += 1
    else
      outcomes[key] = 1
    end
  end

  def find_outcome
    white_wins = outcomes[:white_wins].to_f
    black_wins = outcomes[:black_wins].to_f
    draws = outcomes[:draws].to_f

    numerator = (white_wins - black_wins)
    denominator = (white_wins + black_wins + draws).to_f
    return 0 if numerator == 0
    numerator / denominator
  end
end
