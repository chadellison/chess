class NeuralNetwork
  ALPHA = 0.01

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

  def weighted_sum(input, weights)
    total_weight = 0
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

  def find_outcomes(setup)
    white_wins = setup.outcomes[:white_wins].to_i
    black_wins = setup.outcomes[:black_wins].to_i
    draws = setup.outcomes[:draws].to_i

    total_setup_count = (white_wins + black_wins + draws).to_f
    white_outcomes = white_wins / total_setup_count.to_f
    black_outcomes = black_wins / total_setup_count.to_f
    draw_outcomes = draws / total_setup_count.to_f

    [white_outcomes, black_outcomes, draw_outcomes]
  end

  def propagate_results(setup)
    weight_matrix = find_weights

    outcomes = find_outcomes(setup)

    initial_input = signature_input(setup.signatures)
    predictions = multiply_vector(initial_input, weight_matrix)
    deltas = []

    predictions.size.times do |index|
      delta = predictions[index] - outcomes[index]
      deltas[index] = delta
      puts 'ERROR: ' + (delta ** 2).to_s
    end
    weighted_deltas = weight_deltas(signature_input(setup.signatures), deltas)

    weight_matrix.size.times do |index|
      weight_matrix[index].size.times do |count|
        weight = weight_matrix[index][count]
        puts 'OLD WEIGHT: ' + weight.value
        adjusted_value = (weight.value.to_f - (ALPHA * weighted_deltas[index][count])).to_s
        puts 'ADJUSTED WEIGHT: ' + adjusted_value
        weight.update(value: adjusted_value)
      end
    end
  end

  def weight_deltas(input, deltas)
    weighted_deltas = [[], [], []]

    deltas.size.times do |index|
      input.size.times do |count|
        weighted_deltas[index][count] = input[count] * deltas[index]
      end
    end

    weighted_deltas
  end

  def signature_input(signatures)
    signatures.sort_by(&:signature_type).map { |signature| signature.average_outcome.to_f }
  end

  def relu(input)
    input > 0 ? input : 0
  end
end
