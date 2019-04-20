module OutcomeCalculator
  extend ActiveSupport::Concern

  def outcome_ratio
    return 0 if rank == 0
    rank / total_played
  end

  def rank
    outcomes[:white_wins].to_f - outcomes[:black_wins].to_f
  end

  def total_played
    outcomes[:white_wins].to_f + outcomes[:black_wins].to_f + outcomes[:draws].to_f
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
