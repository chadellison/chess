class AiLogic
  attr_reader :neural_network

  def initialize
    @neural_network = RubyNN::NeuralNetwork.new([16, 20, 15, 10, 3])
    @neural_network.set_weights(JSON.parse(File.read(Rails.root + 'json/weights.json')))
  end

  def analyze(possible_moves, turn)
    weighted_moves = move_analysis(possible_moves)
    best_move_value = find_best_move(weighted_moves, turn)
  end

  def move_analysis(possible_moves)
    weighted_moves = {}
    possible_moves.each do |possible_move|
      input = normalize_values(possible_move.setup.abstraction)
      predictions = neural_network.calculate_prediction(input).last
      weighted_moves[possible_move.value] = predictions
      # puts "#{possible_move.value} ==> #{neural_network.layer_four_predictions}"
    end
    weighted_moves
  end

  def normalize_values(abstraction)
    abstraction.pattern.split('-').map { |value| value.to_f }
  end

  def find_best_move(weighted_moves, turn)
    weighted_moves.max_by { |move_value, predictions| predictions.first }.first
  end

  def random_move(game)
    turn = game.current_turn
    game_pieces = game.pieces.select { |piece| piece.color == turn }
    game_moves = game_pieces.map do |piece|
      piece.valid_moves.map { |move| piece.position_index.to_s + move }
    end.flatten

    game_moves.sample
  end

  def softmax(vector)
    sum = vector.sum.to_f
    vector.map do |value|
      if value == 0
        0
      else
        value / sum
      end
    end
  end

  def calculate_outcomes(abstraction)
    first = 0.0
    second = 0.0
    third = 0.0
    abstraction.setups.each do |setup|
      white_wins = setup.outcomes[:white_wins].to_f
      black_wins = setup.outcomes[:black_wins].to_f
      draws = setup.outcomes[:draws].to_f

      if setup.position_signature[-1] == 'w'
        first += white_wins
        second += black_wins
      else
        second += black_wins
        first += white_wins
      end

      third = draws
    end

    [first, second, third]
  end
end
