class NeuralNetwork
  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      setup = possible_move.setup
      signatures = setup.signatures
      predictions = {
        white: weighted_sum(setup, 'white'),
        black: weighted_sum(setup, 'black'),
        draw: weighted_sum(setup, 'draw')
      }
      weighted_moves[possible_move.value] = predictions
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

  def weighted_sum(setup, win_value)
    setup.signatures.reduce(0) do |total, signature|
      weight = Weight.find_by(weight_type: signature.signature_type, win_value: win_value)
      total + signature.average_outcome * weight.value.to_f
    end
  end
end
