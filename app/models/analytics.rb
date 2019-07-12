class Analytics
  attr_reader :neural_network, :game_move_logic
  include CacheLogic

  def initialize
    @neural_network = NeuralNetwork.new
    @game_move_logic = GameMoveLogic.new
  end

  def move_analytics(analytics_params)
    find_setup(analytics_params[:pieces], analytics_params[:turn])
    if in_cache?('analytics_' + @setup.position_signature)
      JSON.parse(get_from_cache('analytics_' + @setup.position_signature))
    else
      game = load_game(analytics_params[:moves])

      turn = game.moves.size.even? ? 'white' : 'black'
      ai = AiLogic.new(game)
      possible_moves = ai.find_next_moves(turn)
      analyzed_moves = analyzed_moves(possible_moves, turn)

      serialized_moves = AnalyticsSerializer.serialize(analyzed_moves)
      add_to_cache('analytics_' + @setup.position_signature, serialized_moves)
      serialized_moves
    end
  end

  def analyzed_moves(possible_moves, turn)
    neural_network.analyze(possible_moves, turn).map do |next_move, prediction|
      { move: next_move, white: prediction, black: prediction * -1 }
    end
  end

  def find_setup(pieces, turn_code)
    return @setup if @setup.present?

    formatted_pieces = dersialize_pieces(pieces)
    @setup = Setup.find_setup(formatted_pieces, turn_code)
    @setup
  end

  def dersialize_pieces(pieces)
    game_pieces = pieces.map do |piece|
      Piece.new(
        position_index: piece[:positionIndex],
        piece_type: piece[:pieceType],
        color: piece[:color],
        position: piece[:position],
        moved_two: piece[:movedTwo],
        has_moved: piece[:hasMoved]
      )
    end
    game_move_logic.load_move_attributes(game_pieces)
    game_pieces
  end

  def dersialize_moves(moves)
    moves.map { |attributes| Move.new(attributes) }
  end

  def load_game(moves)
    game = Game.new
    game.moves = dersialize_moves(moves)

    if game.moves.blank?
      game.pieces
    else
      game.last_move.setup = @setup
    end
    game
  end
end
