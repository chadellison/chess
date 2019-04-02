class NeuralNetwork
  ALPHA = 0.05

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    weight_matrix = find_weights
    possible_moves.each do |possible_move|
      initial_input = signature_input(possible_move.setup.signatures)
      predictions = multiply_vector(initial_input, weight_matrix)

      weighted_moves[possible_move.value] = predictions
      puts "#{possible_move.value} ==> #{weighted_moves[possible_move.value]}"
    end
    weighted_moves
  end

  def find_weights
    weights = Weight.where(weight_count: 1..12).order(:weight_count)
    [weights[0..3], weights[4..7], weights[8..11]]
  end

  # def layer_two(predictions)
  #   weights = Weight.where(weight_type: ['layer_two 0', 'layer_two 1', 'layer_two 2', 'layer_two 3'])
  #
  #   predictions.each do |output_type, value|
  #     value = relu(value)
  #     weighted_sum([value], weights)
  #   end
  # end

  def weight_deltas(input, deltas)
    weighted_deltas = [[]]
    input.size.times do |index|
      deltas.size.times do |count|
        weighted_deltas[index][count] = input[index] * deltas[count]
      end
    end
    weighted_deltas
  end

  def actual_outcomes(outcome)
    case outcome
    when 1
      [1, 0, 0]
    when 0
      [0, 1, 0]
    when 0.5
      [0, 0, 1]
    end
  end

  def propagate_results(moves, outcome)
    weights_to_be_updated = []
    weight_matrix = find_weights

    outcomes = actual_outcomes(outcome)

    moves.each do |move|
      initial_input = signature_input(move.setup.signatures)
      predictions = multiply_vector(initial_input, weight_matrix)
      deltas = []

      predictions.size.times do |index|
        delta = predictions[index] - outcomes[index]
        deltas[index] = delta
        puts 'ERROR: ' + (delta ** 2).to_s
      end

      weighted_deltas = weight_deltas(initial_input, deltas)

      weight_matrix.size.times do |index|
        weight_matrix[index].size.times do |count|
          weight = weight_matrix[index][count]
          weight.value.to_f -= (ALPHA * weighted_deltas[index][count])
          weights_to_be_updated << weight
        end
      end
    end

    weights_to_be_updated.each(&:save)
  end

  def weighted_sum(input, weights)
    total_weight = 0
    input.size.times do |index|
      total_weight += input[index] * weights[index].value.to_f
    end
    total_weight
  end

  def multiply_vector(input, weight_matrix)
    predictions = []
    3.times do |index|
      predictions[index] = weighted_sum(input, weight_matrix[index])
    end
    predictions
  end

  def signature_input(signatures)
    signatures.order(:signature_type).map { |signature| signature.average_outcome.to_f }
  end

  def relu(input)
    [0, input].max
  end
end
