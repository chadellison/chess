class NeuralNetwork
  ALPHA = 0.001

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    layer_one_weights = find_layer_one_weights
    layer_two_weights = find_layer_two_weights
    possible_moves.each do |possible_move|
      initial_input = signature_input(possible_move.setup.signatures)
      layer_one_predictions = multiply_vector(initial_input, layer_one_weights)
      layer_two_predictions = multiply_vector(relu(layer_one_predictions), layer_two_weights)
      weighted_moves[possible_move.value] = layer_two_predictions
      puts "#{possible_move.value} ==> #{weighted_moves[possible_move.value]}"
    end
    weighted_moves
  end

  def weighted_sum(input, weights)
    total_weight = 0
    raise raise NeuralNetworkError, 'arrays are not equal length' if input.size != weights.size
    input.size.times do |index|
      total_weight += input[index] * weights[index].value.to_f
    end
    total_weight
  end

  def multiply_vector(input, weight_matrix)
    predictions = []
    weight_matrix.size.times do |index|
      predictions[index] = weighted_sum(input, weight_matrix[index])
    end
    predictions
  end

  def find_layer_one_weights
    weights = Weight.where(weight_count: 1..40).order(:weight_count)
    [
      weights[0..4], weights[5..9], weights[10..14], weights[15..19],
      weights[20..24], weights[25..29], weights[30..34], weights[35..39]
    ]
  end

  def find_layer_two_weights
    weights = Weight.where(weight_count: 41..64).order(:weight_count)
    [weights[0..7], weights[8..15], weights[16..23]]
  end

  def find_outcomes(setup)
    [:white_wins, :black_wins, :draws].map do |outcome|
      setup.average_outcome(outcome)
    end
  end

  def train(setup)
    outcomes = find_outcomes(setup)
    layer_one_weights = find_layer_one_weights
    layer_two_weights = find_layer_two_weights

    initial_input = signature_input(setup.signatures)

    layer_one_predictions = multiply_vector(initial_input, layer_one_weights)

    layer_two_predictions = multiply_vector(relu(layer_one_predictions), layer_two_weights)
    layer_two_deltas = find_deltas(layer_two_predictions, outcomes)
    layer_one_deltas = relu_derivative(multiply_vector(layer_two_deltas, layer_two_weights.transpose))

    layer_two_weighted_deltas = calculate_deltas(layer_one_predictions, layer_two_deltas)
    layer_one_weighted_deltas = calculate_deltas(initial_input, layer_one_deltas)

    update_weights(layer_two_weights, layer_two_weighted_deltas)
    update_weights(layer_one_weights, layer_one_weighted_deltas)
  end

  def find_deltas(predictions, outcomes)
    deltas = []
    predictions.size.times do |index|
      delta = predictions[index] - outcomes[index]
      deltas[index] = delta
      puts 'ERROR: ' + (delta ** 2).to_s
    end

    deltas
  end

  def update_weights(weight_matrix, weighted_deltas)
    weight_matrix.size.times do |index|
      weight_matrix[index].size.times do |count|
        weight = weight_matrix[index][count]
        puts 'OLD WEIGHT: ' + weight.value
        adjusted_value = (weight.value.to_f + (ALPHA * weighted_deltas[index][count])).to_s
        puts 'ADJUSTED WEIGHT: ' + adjusted_value
        weight.update(value: adjusted_value)
      end
    end
  end

  def calculate_deltas(input, deltas)
    weighted_deltas = []
    deltas.each { weighted_deltas.push([]) }

    deltas.size.times do |index|
      input.size.times do |count|
        weighted_deltas[index][count] = input[count] * deltas[index]
      end
    end

    weighted_deltas
  end

  def signature_input(signatures)
    signatures.sort_by(&:signature_type).map { |signature| signature.value.to_f }
  end

  def relu(input)
    input.map { |value| value > 0 ? value : 0 }
  end

  def relu_derivative(output)
    output.map { |value| value > 0 ? 1 : 0 }
  end
end
