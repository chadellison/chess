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
    win_ratio
    # game = Game.new
    # move_count = 0
    # game.moves = moves.map do |move_value|
    #   move_count += 1
    #   Move.new(value: move_value, move_count: move_count)
    # end
    #
    # if game.moves.blank?
    #   game.pieces
    # else
    #   game.last_move.setup = setup
    # end
    # turn = game.moves.size.even? ? 'white' : 'black'
    # game.find_next_moves(turn)
  end
end
