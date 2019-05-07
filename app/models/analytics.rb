class Analytics
  include CacheLogic

  def neural_network
    @neural_network = NeuralNetwork.new
  end

  def move_analytics(analytics_params)
    find_setup(analytics_params[:pieces], analytics_params[:turn])
    if in_cache?(@setup.position_signature)
      JSON.parse(get_from_cache(@setup.position_signature))
    else
      game = load_game(analytics_params[:moves])

      turn = game.moves.size.even? ? 'white' : 'black'
      ai = AiLogic.new(game)
      possible_moves = ai.find_next_moves(turn)
      analyzed_moves = analyzed_moves(possible_moves, turn)

      serialized_moves = AnalyticsSerializer.serialize(analyzed_moves)
      add_to_cache(@setup.position_signature, serialized_moves)
      serialized_moves
    end
  end

  def analyzed_moves(possible_moves, turn)
    neural_network.move_analysis(possible_moves, turn).map do |next_move, prediction|
      { move: next_move, white: prediction, black: prediction * -1 }
    end
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

  def find_setup(pieces, turn_code)
    return @setup if @setup.present?

    formatted_pieces = dersialize_pieces(pieces)
    @setup = Setup.find_setup(formatted_pieces, turn_code)
    @setup
  end

  def dersialize_pieces(pieces)
    pieces.map do |piece|
      Piece.new(
        position_index: piece[:positionIndex],
        piece_type: piece[:pieceType],
        color: piece[:color],
        position: piece[:position],
        moved_two: piece[:movedTwo],
        has_moved: piece[:hasMoved]
      )
    end
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
