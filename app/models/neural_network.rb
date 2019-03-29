class NeuralNetwork
  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      setup = possible_move.setup
      signatures = setup.signatures
      total_weight = signatures.reduce(0) { |weight, signature| weight + signature.average_outcome }

      total_weight *= -1 if game_turn == 'black'
      weighted_moves[possible_move.value] = total_weight
      puts "#{possible_move.value} ==> #{weighted_moves[possible_move.value]}"
    end
    weighted_moves
  end

  def propagate_results(moves, outcome)
    moves.each do |move|
      setup = move.setup
      setup.update_outcomes(outcome)
      setup.signatures.each { |signature| signature.update_outcomes(outcome) }
    end
  end
end
