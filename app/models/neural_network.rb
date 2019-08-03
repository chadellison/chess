class NeuralNetwork
  ALPHA = 0.05
  # WEIGHT_COUNTS = [30, 18, 3]
  # OFFSETS = [0, 30, 48]
  # VECTOR_COUNTS = [5, 6, 3]
  WEIGHT_COUNTS = [120, 96, 8]
  OFFSETS = [0, 120, 216]
  VECTOR_COUNTS = [10, 12, 8]

  include CacheLogic

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}
    layer_one_weights = find_weights(WEIGHT_COUNTS[0], OFFSETS[0], VECTOR_COUNTS[0])
    layer_two_weights = find_weights(WEIGHT_COUNTS[1], OFFSETS[1], VECTOR_COUNTS[1])
    layer_three_weights = find_weights(WEIGHT_COUNTS[2], OFFSETS[2], VECTOR_COUNTS[2])

    possible_moves.each do |possible_move|
      final_prediction = calculate_prediction(possible_move.setup, layer_one_weights, layer_two_weights, layer_three_weights)
      weighted_moves[possible_move.value] = final_prediction
      puts "#{possible_move.value} ==> #{weighted_moves[possible_move.value]}"
    end
    weighted_moves
  end

  def calculate_prediction(setup, layer_one_weights, layer_two_weights, layer_three_weights)
    initial_input = signature_input(setup.signatures)
    layer_one_predictions = multiply_vector(initial_input, layer_one_weights)
    layer_two_predictions = multiply_vector(layer_one_predictions, layer_two_weights)
    multiply_vector(layer_two_predictions, layer_three_weights).first
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

  def find_weights(weight_amount, offset, slice_value)
    range = ((offset + 1)..(offset + weight_amount))
    weights = Weight.where(weight_count: range).order(:weight_count)

    weights.each_slice(slice_value).to_a
  end

  def train(setup)
    outcome = Math.tanh(setup.outcome_ratio)

    layer_one_weights = find_weights(WEIGHT_COUNTS[0], OFFSETS[0], VECTOR_COUNTS[0])
    layer_two_weights = find_weights(WEIGHT_COUNTS[1], OFFSETS[1], VECTOR_COUNTS[1])
    layer_three_weights = find_weights(WEIGHT_COUNTS[2], OFFSETS[2], VECTOR_COUNTS[2])

    initial_input = signature_input(setup.signatures)

    layer_one_predictions = tanh(multiply_vector(initial_input, layer_one_weights))
    layer_two_predictions = tanh(multiply_vector(layer_one_predictions, layer_two_weights))
    final_predictions = tanh(multiply_vector(layer_two_predictions, layer_three_weights))

    final_delta = find_delta(tanh(final_predictions).first, outcome)
    layer_two_deltas = tanh_derivative(multiply_vector([final_delta], layer_three_weights.transpose))
    layer_one_deltas = tanh_derivative(multiply_vector(layer_two_deltas, layer_two_weights.transpose))

    layer_three_weighted_deltas = calculate_deltas(layer_two_predictions, [final_delta])
    layer_two_weighted_deltas = calculate_deltas(layer_one_predictions, layer_two_deltas)
    layer_one_weighted_deltas = calculate_deltas(initial_input, layer_one_deltas)

    update_weights(layer_three_weights, layer_three_weighted_deltas)
    update_weights(layer_two_weights, layer_two_weighted_deltas)
    update_weights(layer_one_weights, layer_one_weighted_deltas)
  end

  def find_delta(prediction, outcome)
    delta = prediction - outcome
    error = delta ** 2
    update_error_rate(error)
    puts 'ERROR: ' + error.to_s
    puts 'DELTA: ' + delta.to_s
    delta
  end

  def update_weights(weight_matrix, weighted_deltas)
    weight_matrix.size.times do |index|
      weight_matrix[index].size.times do |count|
        weight = weight_matrix[index][count]
        adjusted_value = (weight.value.to_f - (ALPHA * weighted_deltas[index][count]))
        weight.update(value: adjusted_value.to_s) if adjusted_value > 0
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
    signatures.sort_by(&:signature_type).map(&:value)
  end

  # def leaky_relu(input)
  #   input.map { |value| value > 0 ? value : 0.01 }
  # end
  #
  # def relu_derivative(output)
  #   output.map { |value| value > 0 ? 1 : 0.01 }
  # end

  def tanh(input)
    input.map { |value| Math.tanh(value) }
  end

  def tanh_derivative(output)
    output.map { |output| 1 - Math.tanh(output) ** 2 }
  end

  def update_error_rate(error)
    error_object = JSON.parse(get_from_cache('error_rate')).symbolize_keys
    error_object[:count] += 1
    error_object[:error] += error
    add_to_cache('error_rate', error_object)
  end
end
