class AiLogic
  attr_reader :neural_network

  def initialize
    @neural_network = NeuralNetwork.new
  end

  def analyze(possible_moves)
    weighted_moves = move_analysis(possible_moves)
    best_move_value = find_best_move(weighted_moves)
  end

  def move_analysis
    weighted_moves = {}

    possible_moves.each do |possible_move|
      neural_network.calculate_prediction(possible_move.setup.abstraction)

      weighted_moves[possible_move.value] = neural_network.layer_three_predictions
      puts "#{possible_move.value} ==> #{neural_network.layer_three_predictions}"
    end
    weighted_moves
  end

  def find_best_move(weighted_moves)
    weighted_moves.max_by do |move_value, predictions|
      predictions.first
    end.first
  end
end
