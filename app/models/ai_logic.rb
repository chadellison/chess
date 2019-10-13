class AiLogic
  attr_reader :neural_network

  include CacheLogic

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
      # neural_network.calculate_prediction(possible_move.setup.abstraction)
      # weighted_moves[possible_move.value] = neural_network.layer_four_predictions
      # puts "#{possible_move.value} ==> #{neural_network.layer_four_predictions}"
      setup = possible_move.setup

      if in_cache?('eval_' + setup.position_signature)
        evaluation = get_from_cache('eval_' + setup.position_signature)
      elsif possible_move.setup.find_outcome.present?
        evaluation = possible_move.setup.find_outcome
      else
        # send abstractions through the network
      end
      puts "#{possible_move.value} ==> #{evaluation}"
      weighted_moves[possible_move.value] = evaluation
    end
    weighted_moves
  end

  def find_best_move(weighted_moves, turn)
    if turn == 'white'
      weighted_moves.max_by { |move_value, evaluation| evaluation }.first
    else
      weighted_moves.min_by { |move_value, evaluation| evaluation }.first
    end
  end
end
