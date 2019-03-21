module WeightCalculator
  extend ActiveSupport::Concern

  def rank
    outcomes[:white_wins].to_i - outcomes[:black_wins].to_i
  end

  def average_outcome
    return 0 if rank == 0
    rank / (outcomes[:white_wins].to_f + outcomes[:black_wins].to_f + outcomes[:draws].to_f)
  end

  def update_outcomes(outcome)
    key = { 1 => :white_wins, -1 => :black_wins, 0 => :draws }[outcome]

    if outcomes[key].present?
      outcomes[key] += 1
    else
      outcomes[key] = 1
    end
    save
  end
end
