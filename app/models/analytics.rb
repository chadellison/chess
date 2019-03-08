class Analytics
  attr_reader :setup

  def self.fetch_analytics(signature, type)
    analytics = Analytics.new(Setup.find_by(position_signature: signature))
    case type
    when 'pie'
      attributes = analytics.win_ratio
    when 'line'
      attributes = analytics.next_move_weights
    end

    AnalyticsSerializer.serialize(attributes)
  end

  def initialize(setup)
    @setup = setup
  end

  def win_ratio
    setup_outcomes = {}
    setup_outcomes = setup.outcomes if setup.present?
    {
      whiteWins: setup_outcomes[:white_wins].to_i,
      blackWins: setup_outcomes[:black_wins].to_i,
      draws: setup_outcomes[:draws].to_i
    }
  end

  def next_move_weights
    win_ratio
    # game = Game.new
    # return {} if setup.blank?
    # if game.in_cache?(setup.position_signature)
    #   game.get_next_moves_from_cache(setup_key)
    # else
    #   pieces = game.send(:pieces_from_signature, setup.position_signature)
    #   # pieces = game.pieces_from_signature(setup.position_signature)
    #   next_moves = pieces.select { |piece| piece.color == game_turn }.map do |piece|
    #     game.all_next_moves_for_piece(piece)
    #   end.flatten
    #
    #   next_moves.map do |next_move|
    #     {next_move.value => next_move.setup.average_outcome}
    #   end
    # end
  end
end
