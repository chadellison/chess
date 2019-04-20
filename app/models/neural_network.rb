class NeuralNetwork
  ALPHA = 0.01

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    layer_one_weights = find_layer_one_weights
    layer_two_weights = find_layer_two_weights
    possible_moves.each do |possible_move|
      final_prediction = calculate_prediction(possible_move.setup, layer_one_weights, layer_two_weights)
      weighted_moves[possible_move.value] = final_prediction
      puts "#{possible_move.value} ==> #{weighted_moves[possible_move.value]}"
    end
    weighted_moves
  end

  def calculate_prediction(setup, layer_one_weights, layer_two_weights)
    initial_input = signature_input(setup.signatures)
    layer_one_predictions = multiply_vector(initial_input, layer_one_weights)
    prediction = multiply_vector(tanh(layer_one_predictions), layer_two_weights).first
    prediction
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
    weights = Weight.where(weight_count: 41..48).order(:weight_count)
    [weights[0..7]]
  end

  def train(setup)
    outcome = setup.outcome_ratio
    layer_one_weights = find_layer_one_weights
    layer_two_weights = find_layer_two_weights
    initial_input = signature_input(setup.signatures)

    layer_one_predictions = multiply_vector(initial_input, layer_one_weights)

    final_prediction = tanh(multiply_vector(tanh(layer_one_predictions), layer_two_weights)).first
    final_delta = find_delta(final_prediction, outcome)
    layer_one_deltas = tanh_derivative(multiply_vector([final_delta], layer_two_weights.transpose))

    layer_two_weighted_deltas = calculate_deltas(layer_one_predictions, [final_delta])
    layer_one_weighted_deltas = calculate_deltas(initial_input, layer_one_deltas)

    update_weights(layer_two_weights, layer_two_weighted_deltas)
    update_weights(layer_one_weights, layer_one_weighted_deltas)
  end

  def find_delta(prediction, outcome)
    delta = prediction - outcome
    error = delta ** 2
    puts 'ERROR: ' + error.to_s
    delta
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
    # signatures.sort_by(&:signature_type).map { |signature| signature.value.to_f }
    signatures.sort_by(&:signature_type).map { |signature| signature.outcome_ratio.to_f }
  end

  # def leaky_relu(input)
  #   input.map { |value| value > 0 ? value : 0.01 }
  # end

  # def relu_derivative(output)
  #   output.map { |value| value > 0 ? 1 : 0.01 }
  # end

  def tanh(input)
    input.map { |value| Math.tanh(value) }
  end

  def tanh_derivative(output)
    output.map { |output| 1 - Math.tanh(output) ** 2 }
  end
end
