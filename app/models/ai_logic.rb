class AiLogic
  # attr_reader :neural_network

  include CacheLogic

  def initialize
    # @neural_network = NeuralNetwork.new
  end

  def analyze(possible_moves, turn)
    weighted_moves = move_analysis(possible_moves)
    best_move_value = find_best_move(weighted_moves, turn)
  end

  def move_analysis(possible_moves)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      evaluation = evaluate_move(possible_move)
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

  def evaluate_move(possible_move)
    setup = possible_move.setup
    position_signature = setup.position_signature
    outcome = setup.find_outcome
    abstractions = setup.abstractions

    if in_cache?('eval_' + position_signature)
      get_from_cache('eval_' + position_signature)
    elsif outcome.present?
      outcome
    else
      abstractions.map(&:find_outcome).sum / abstractions.size
      # input = abstractions.map(&:find_outcome)
      # neural_network.calculate_prediction(input)
    end
  end
end
