class NeuralNetwork
  ALPHA = 0.05

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      signatures = ordered_signatures(possible_move.setup.signatures)
      weights = Weight.where(weight_type: signatures.pluck(:signature_type))
      white_weights = filter_and_sort(weights, 'white')
      black_weights = filter_and_sort(weights, 'black')
      draw_weights = filter_and_sort(weights, 'draw')

      predictions = {
        white: weighted_sum(signatures, white_weights),
        black: weighted_sum(signatures, black_weights),
        draw: weighted_sum(signatures, draw_weights)
      }
      weighted_moves[possible_move.value] = predictions
      puts "#{possible_move.value} ==> #{weighted_moves[possible_move.value]}"
    end
    weighted_moves
  end

  def propagate_results(moves, outcome)
    weights_to_be_updated = []

    moves.each do |move|
      win_values = ['white', 'black', 'draw']
      signatures = ordered_signatures(move.setup.signatures)
      weights = Weight.where(weight_type: signatures.pluck(:signature_type))

      win_values.each do |win_value|
        sorted_weights = filter_and_sort(weights, win_value)
        prediction = weighted_sum(signatures, sorted_weights)

        signatures.each_with_index do |signature, index|
          weight = sorted_weights[index]

          adjusted_weight_value = adjust_weight(
            signature.average_outcome.to_f, weight.value.to_f, outcome, prediction
          )
          puts 'old weight: ' + weight.value
          weight.value = adjusted_weight_value.to_s
          puts 'adjusted weight: ' + weight.value
          weights_to_be_updated << weight
        end
      end
    end
    weights_to_be_updated.each(&:save)
  end

  def adjust_weight(input, weight, outcome, prediction)
    puts 'PREDICTION: ' + (input * weight).to_s
    puts 'OUTCOME: ' + outcome.to_s
    puts 'ERROR: ' + (((input * weight) - outcome) ** 2).to_s
    weight - (ALPHA * derivative(input, prediction - outcome))
  end

  def weighted_sum(signatures, weights)
    total_weight = 0
    signatures.each_with_index do |signature, index|
      total_weight += signature.average_outcome.to_f * weights[index].value.to_f
    end
    total_weight
  end

  def derivative(input, delta)
    input * delta
  end

  def ordered_signatures(signatures)
    signatures.order(:signature_type)
  end

  def filter_and_sort(weights, win_value)
    weights.select { |weight| weight.win_value == win_value }.sort_by(&:weight_type)
  end
end
