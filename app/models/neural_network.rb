class NeuralNetwork
  ALPHA = 0.01
  WEIGHT_COUNTS = [200, 200, 10]
  OFFSETS = [0, 200, 200]
  VECTOR_COUNTS = [10, 20, 10]

  include CacheLogic

  attr_accessor :layer_one_weights, :layer_two_weights, :layer_three_weights,
    :layer_one_predictions, :layer_two_predictions, :layer_three_predictions,
    :layer_one_deltas, :layer_two_deltas, :layer_three_deltas

  def initialize
    @layer_one_weights = find_weights(0)
    @layer_two_weights = find_weights(1)
    @layer_three_weights = find_weights(2)
    @layer_one_predictions = []
    @layer_two_predictions = []
    @layer_three_predictions = []
    @layer_one_deltas = []
    @layer_two_deltas = []
    @layer_three_deltas = []
  end

  def calculate_prediction(abstraction)
    input = normalize_values(abstraction)
    @layer_one_predictions = leaky_relu(multiply_vector(input, layer_one_weights))
    @layer_two_predictions = leaky_relu(multiply_vector(layer_one_predictions, layer_two_weights))
    @layer_three_predictions = (multiply_vector(layer_two_predictions, layer_three_weights))
  end

  def weighted_sum(input, weights)
    total_weight = 0
    raise raise NeuralNetworkError, 'arrays are not equal length' if input.size != weights.size
    input.size.times do |index|
      total_weight += input[index] * weights[index]
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

  def find_weights(index)
    weight_amount, offset, slice_value = WEIGHT_COUNTS[index], OFFSETS[index], VECTOR_COUNTS[index]
    range = ((offset + 1)..(offset + weight_amount))
    weights = Weight.where(weight_count: range).order(:weight_count).map do |weight|
      weight.value.to_f
    end

    weights.each_slice(slice_value).to_a
  end

  def train(abstraction)
    input = normalize_values(abstraction)

    calculate_prediction(abstraction)
    outcomes = calculate_outcomes(abstraction)

    update_deltas(outcomes)
    update_weights(layer_three_deltas, layer_three_weights)
    update_weights(layer_two_deltas, layer_two_weights)
    update_weights(layer_one_deltas, layer_one_weights)
  end

  def update_deltas(outcomes)
    @layer_three_deltas = find_deltas(layer_three_predictions, outcomes)
    l_3_weighted = multiply_vector(layer_three_deltas, layer_three_weights.transpose)
    @layer_two_deltas = back_propagation_multiplyer(l_3_weighted, relu_derivative(layer_two_predictions))
    l_2_weighted = multiply_vector(layer_two_deltas, layer_two_weights.transpose)
    @layer_one_deltas = back_propagation_multiplyer(l_2_weighted, relu_derivative(layer_one_predictions))
  end

  def save_weights
    all_weight_values = layer_one_weights.flatten +
                        layer_two_weights.flatten +
                        layer_three_weights.flatten

    Weight.order(:weight_count).each_with_index do |weight, index|
      weight.update(value: all_weight_values[index].to_s)
    end
  end

  def find_deltas(predictions, outcomes)
    deltas = []
    predictions.size.times do |index|
      delta = predictions[index] - outcomes[index]
      deltas[index] = delta
      error = delta ** 2
      # puts 'ERROR: ' + error.to_s
      update_error_rate(error)
    end

    deltas
  end

  def update_weights(weighted_deltas, weight_matrix)
    weight_matrix.size.times do |index|
      weight_matrix[index].size.times do |count|
        weight = weight_matrix[index][count]
        adjusted_value = (weight - (ALPHA * weighted_deltas[index]))
        weight_matrix[index][count] = adjusted_value if adjusted_value > 0
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

  def leaky_relu(input)
    input.map { |value| value > 0 ? value : 0.01 }
  end

  def relu_derivative(output)
    output.map { |value| value > 0 ? 1 : 0.01 }
  end

  def calculate_outcomes(abstraction)
    numerator = 0.0
    denominator = 0.0

    abstraction.setups.each do |setup|
      white_wins = setup.outcomes[:white_wins].to_f
      black_wins = setup.outcomes[:black_wins].to_f

      if setup.position_signature[-1] == 'w'
        numerator += white_wins
      else
        numerator += black_wins
      end
      denominator += white_wins + black_wins
    end

    [handle_ratio(numerator, denominator)]
  end

  def handle_ratio(numerator, denominator)
    return 0 if numerator == 0 || denominator == 0
    numerator / denominator
  end

  # def tanh(input)
  #   input.map { |value| Math.tanh(value) }
  # end
  #
  # def tanh_derivative(output)
  #   output.map { |output| 1 - (Math.tanh(output) ** 2) }
  # end

  def update_error_rate(error)
    error_object = JSON.parse(get_from_cache('error_rate')).symbolize_keys
    error_object[:count] += 1
    error_object[:error] += error
    add_to_cache('error_rate', error_object)
  end

  def normalize_values(abstraction)
    abstraction.pattern.split('-').map { |value| value.to_f }
  end

  def back_propagation_multiplyer(v1, v2)
    v1.zip(v2).map { |set| set[0] * set[1] }
  end
end
