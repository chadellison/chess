class NeuralNetwork
  ALPHA = 0.01
  WEIGHT_COUNTS = [600, 160, 8]
  OFFSETS = [0, 600, 760]
  VECTOR_COUNTS = [30, 20, 8]

  include CacheLogic

  attr_reader :layer_one_weights, :layer_two_weights, :layer_three_weights

  def initialize
    @layer_one_weights = find_weights(WEIGHT_COUNTS[0], OFFSETS[0], VECTOR_COUNTS[0])
    @layer_two_weights = find_weights(WEIGHT_COUNTS[1], OFFSETS[1], VECTOR_COUNTS[1])
    @layer_three_weights = find_weights(WEIGHT_COUNTS[2], OFFSETS[2], VECTOR_COUNTS[2])
  end

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      final_predictions = calculate_prediction(
        possible_move.setup.abstraction.pattern.split('.').map(&:to_i)
      )

      weighted_moves[possible_move.value] = final_predictions
      puts "#{possible_move.value} ==> #{final_predictions}"
    end
    weighted_moves
  end

  def calculate_prediction(initial_input)
    layer_one_predictions = multiply_vector(initial_input, layer_one_weights)
    layer_two_predictions = multiply_vector(layer_one_predictions, layer_two_weights)
    multiply_vector(layer_two_predictions, layer_three_weights)
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

  def train(abstraction)
    initial_input = abstraction.pattern.split('.').map(&:to_i)
    outcomes = calculate_outcomes(abstraction)

    layer_one_predictions = tanh(multiply_vector(initial_input, layer_one_weights))
    layer_two_predictions = tanh(multiply_vector(layer_one_predictions, layer_two_weights))
    final_predictions = tanh(multiply_vector(layer_two_predictions, layer_three_weights))

    final_deltas = find_deltas(final_predictions, outcomes)
    layer_two_deltas = tanh_derivative(multiply_vector(final_deltas, layer_three_weights.transpose))
    layer_one_deltas = tanh_derivative(multiply_vector(layer_two_deltas, layer_two_weights.transpose))

    layer_three_weighted_deltas = calculate_deltas(layer_two_predictions, final_deltas)
    layer_two_weighted_deltas = calculate_deltas(layer_one_predictions, layer_two_deltas)
    layer_one_weighted_deltas = calculate_deltas(initial_input, layer_one_deltas)

    update_weights(layer_three_weights, layer_three_weighted_deltas)
    update_weights(layer_two_weights, layer_two_weighted_deltas)
    update_weights(layer_one_weights, layer_one_weighted_deltas)
  end

  def save_weights
    layer_one_weights.flatten.each(&:save)
    layer_two_weights.flatten.each(&:save)
    layer_three_weights.flatten.each(&:save)
  end

  def find_deltas(predictions, outcomes)
    deltas = []
    predictions.size.times do |index|
      delta = predictions[index] - outcomes[index]
      deltas[index] = delta
      error = delta ** 2
      puts 'ERROR: ' + error.to_s
      update_error_rate(error)
    end

    deltas
  end

  def update_weights(weight_matrix, weighted_deltas)
    weight_matrix.size.times do |index|
      weight_matrix[index].size.times do |count|
        weight = weight_matrix[index][count]
        adjusted_value = (weight.value.to_f - (ALPHA * weighted_deltas[index][count]))
        weight.value = adjusted_value.to_s if adjusted_value > 0
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

  # def leaky_relu(input)
  #   input.map { |value| value > 0 ? value : 0.01 }
  # end
  #
  # def relu_derivative(output)
  #   output.map { |value| value > 0 ? 1 : 0.01 }
  # end

  def calculate_outcomes(abstraction)
    white_wins = 0.0
    black_wins = 0.0
    draws = 0.0
    outcome = abstraction.setups.find_each do |setup|
      white_wins += setup.outcomes[:white_wins].to_i
      black_wins += setup.outcomes[:black_wins].to_i
      draws += setup.outcomes[:draws].to_i
    end

    total_games = white_wins + black_wins + draws

    [handle_ratio(white_wins - black_wins, total_games)]
  end

  def handle_ratio(numerator, denominator)
    return 0 if numerator == 0 || denominator == 0
    numerator / denominator
  end

  def tanh(input)
    input.map { |value| Math.tanh(value) }
  end

  def tanh_derivative(output)
    output.map { |output| 1 - Math.tanh(output) ** 2 }
  end

  def update_error_rate(error)
    value = error > 1 ? 1 : 0
    error_object = JSON.parse(get_from_cache('error_rate')).symbolize_keys
    error_object[:count] += 1
    error_object[:error] += value
    add_to_cache('error_rate', error_object)
  end
end
