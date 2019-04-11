module OutcomeCalculator
  extend ActiveSupport::Concern

  def average_outcome(result)
    given_outcome = outcomes[result].to_f
    return 0 if given_outcome == 0

    given_outcome / total_played
  end

  def total_played
    outcomes[:white_wins].to_f + outcomes[:black_wins].to_f + outcomes[:draws].to_f
  end

  def update_outcomes(outcome)
    key = { '1' => :white_wins, '0' => :black_wins, '0.5' => :draws }[outcome]

    if outcomes[key].present?
      outcomes[key] += 1
    else
      outcomes[key] = 1
    end
    save
  end
end
