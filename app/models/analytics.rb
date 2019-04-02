class Analytics
  attr_reader :setup, :neural_network

  def initialize(setup)
    @setup = setup
    @neural_network = NeuralNetwork.new
  end

  def win_ratio
    setup_outcomes = {}
    setup_outcomes = setup.outcomes if setup.present?
    attributes = {
      whiteWins: setup_outcomes[:white_wins].to_i,
      blackWins: setup_outcomes[:black_wins].to_i,
      draws: setup_outcomes[:draws].to_i
    }
    AnalyticsSerializer.serialize(attributes)
  end

  def next_move_analytics(moves)
    game = Game.new
    game.moves = moves.map { |attributes| Move.new(attributes) }

    if game.moves.blank?
      game.pieces
    else
      game.last_move.setup = setup
    end

    turn = game.moves.size.even? ? 'white' : 'black'
    ai = AiLogic.new(game)
    possible_moves = ai.find_next_moves(turn)
    analyzed_moves = neural_network.move_analysis(possible_moves, turn).map do |next_move, analytics|
      analytics[:move] = next_move
      analytics
    end
    AnalyticsSerializer.serialize(analyzed_moves)
  end

  def find_weight(signatures, signature_type)
    signature = signatures.detect do |signature|
      signature.signature_type == signature_type
    end
    return 0 if signature.blank?
    signature.average_outcome
  end
end
