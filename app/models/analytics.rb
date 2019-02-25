class Analytics
  attr_reader :setup, :white_wins, :black_wins, :draws

  def initialize(setup)
    @setup = setup
    @white_wins = 0
    @black_wins = 0
    @draws = 0
  end

  def find_outcomes
    if setup.present?
      @white_wins = setup.outcomes.count { |outcome| outcome == 1 }
      @black_wins = setup.outcomes.count { |outcome| outcome == -1 }
      @draws = setup.outcomes.count { |outcome| outcome == 0 }
    end
  end
end
