class Analytics
  attr_reader :ai_logic, :game_move_logic
  include CacheLogic

  def initialize
    @ai_logic = AiLogic.new
    @game_move_logic = GameMoveLogic.new
  end

  def move_analytics(analytics_params)
    opponent_color_code = analytics_params[:turn] == 'w' ? 'b' : 'w'
    deserialized_pieces = dersialize_pieces(analytics_params[:pieces])
    setup_signature = Setup.create_signature(deserialized_pieces, opponent_color_code)

    if in_cache?('analytics_' + setup_signature)
      JSON.parse(get_from_cache('analytics_' + setup_signature))
    else
      game = load_game(analytics_params[:moves], setup_signature)
      turn = analytics_params[:turn] == 'w' ? 'white' : 'black'
      move_count = analytics_params[:moves].count
      possible_moves = game_move_logic.find_next_moves(game.pieces, turn, move_count + 1)
      analyzed_moves = analyze_moves(possible_moves, analytics_params[:turn])

      serialized_moves = AnalyticsSerializer.serialize(analyzed_moves)
      add_to_cache('analytics_' + setup_signature, serialized_moves)
      serialized_moves
    end
  end

  def analyze_moves(possible_moves, turn_code)
    ai_logic.move_analysis(possible_moves).map do |next_move, predictions|
      prediction = predictions[0]

      white_prediction = turn_code == 'w' ? prediction : prediction * -1
      black_prediction = turn_code == 'b' ? prediction : prediction * -1
      {
        move: next_move,
        white: white_prediction,
        black: black_prediction
      }
    end
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

  def load_game(moves, setup_signature)
    game = Game.new
    game.moves = dersialize_moves(moves)

    if !game.moves.blank?
      game.last_move.setup = Setup.new(position_signature: setup_signature)
    end
    game
  end
end
