class Analytics
  attr_reader :setup, :neural_network

  def initialize(setup)
    @setup = setup
    @neural_network = NeuralNetwork.new
  end

  def move_analytics(moves)
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
    analyzed_moves = neural_network.move_analysis(possible_moves, turn).map do |next_move, prediction|
      { move: next_move, white: prediction, black: prediction * -1 }
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

  def initial_outcomes
    white_wins = Game.where(outcome: WHITE_WINS).count
    black_wins = Game.where(outcome: BLACK_WINS).count
    draws = Game.where(outcome: DRAW).count
    { white_wins: white_wins, black_wins: black_wins, draws: draws }
  end
end
