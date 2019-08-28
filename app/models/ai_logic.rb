class AiLogic
  attr_reader :neural_network

  def initialize
    @neural_network = NeuralNetwork.new
  end

  def analyze(possible_moves)
    weighted_moves = neural_network.move_analysis(possible_moves)
    best_move_value = find_best_move(weighted_moves)
  end

  def find_best_move(weighted_moves)
    weighted_moves.max_by do |move_value, predictions|
      predictions.first
    end.first
  end
end
