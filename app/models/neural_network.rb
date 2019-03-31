class NeuralNetwork
  ALPHA = 0.01

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      signatures = ordered_signatures(possible_move.setup.signatures)
      predictions = {
        white: calculate_prediction(signatures, 'white'),
        black: calculate_prediction(signatures, 'black'),
        draw: calculate_prediction(signatures, 'draw')
      }
      weighted_moves[possible_move.value] = predictions
      puts "#{possible_move.value} ==> #{weighted_moves[possible_move.value]}"
    end
    weighted_moves
  end

  def propagate_results(moves, outcome)
    moves.each do |move|
      setup = move.setup

      win_values = ['white', 'black', 'draw']
      # black win = 0
      # white win = 1
      # draw win = 0.5

      signatures = ordered_signatures(setup.signatures)
      win_values.each do |win_value|

        weights = ordered_weights(signatures.pluck(:signature_type), win_value)

        signatures.each_with_index do |signature, index|
          adjusted_weight_value = adjust_weight(
            signature.average_outcome.to_f,
            weights[index].value.to_f,
            outcome
          )
          weight.update(value: adjusted_weight_value.to_s)
        end
      end
    end
  end

  def adjust_weight(input, weight, outcome)
    prediction = input * weight
    weight - (ALPHA * derivative(input, prediction, outcome))
  end

  def calculate_prediction(signatures, win_value)
    weights = ordered_weights(signatures.pluck(:signature_type), win_value)
    weighted_sum(signatures, weights)
  end

  def weighted_sum(signatures, weights)
    total_weight = 0
    signatures.each_with_index do |signature, index|
      total_weight += signature.average_outcome.to_f * weights[index].value.to_f
    end
    total_weight
  end

  def derivative(input, prediction, outcome)
    input * (prediction - outcome)
  end

  def ordered_signatures(signatures)
    signatures.order(:signature_type)
  end

  def ordered_weights(weight_types, win_value)
    Weight.where(weight_type: weight_types, win_value: win_value)
      .order(:weight_type)
  end
end
