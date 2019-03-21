class OutcomePropagator
  def propagate_results(moves, outcome)
    moves.each do |move|
      setup = move.setup
      setup.update_outcomes(outcome)
      setup.signatures.each { |signature| signature.update_outcomes(outcome) }
    end
  end
end
