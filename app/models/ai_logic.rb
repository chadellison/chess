class AiLogic
  attr_reader :neural_network

  def initialize
    @neural_network = NeuralNetwork.new
  end

  def analyze(possible_moves, game_turn)
    weighted_moves = neural_network.move_analysis(possible_moves, game_turn)
    best_move_value = find_best_move(weighted_moves, game_turn)
  end

  def find_best_move(weighted_moves, game_turn)
    weighted_moves.max_by do |move_value, prediction|
      prediction *= -1 if game_turn == 'black'
      prediction
    end.first
  end
end
