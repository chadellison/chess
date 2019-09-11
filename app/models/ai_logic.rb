class AiLogic
  attr_reader :neural_network

  def initialize
    @neural_network = NeuralNetwork.new
  end

  def analyze(possible_moves, turn)
    weighted_moves = move_analysis(possible_moves)
    best_move_value = find_best_move(weighted_moves, turn)
  end

  def move_analysis(possible_moves)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      neural_network.calculate_prediction(possible_move.setup.abstraction)
      weighted_moves[possible_move.value] = neural_network.layer_three_predictions
      puts "#{possible_move.value} ==> #{neural_network.layer_three_predictions}"
    end
    weighted_moves
  end

  def find_best_move(weighted_moves, turn)
    weighted_moves.max_by { |move_value, predictions| predictions.first }.first
  end
end
