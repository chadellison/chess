class Analytics
  attr_reader :setup

  def initialize(setup)
    @setup = setup
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
    attributes = ai.find_next_moves(turn).map do |move|
      { move: move.value, weight: move.setup.average_outcome }
    end
    AnalyticsSerializer.serialize(attributes)
  end
end
