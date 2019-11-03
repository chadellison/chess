class Analytics
  attr_reader :ai_logic, :game_move_logic, :pgn_logic
  include CacheLogic

  def initialize
    @ai_logic = AiLogic.new
    @game_move_logic = GameMoveLogic.new
    @pgn_logic = PgnLogic.new
  end

  def move_analytics(analytics_params)
    deserialized_pieces = dersialize_pieces(analytics_params[:pieces])
    notation = analytics_params[:notation]
    fen_data = pgn_logic.convert_to_fen(notation)
    game_data = GameData.new(deserialized_pieces, fen_data)
    setup = Setup.find_setup(game_data)

    if in_cache?('analytics_' + setup.position_signature)
      JSON.parse(get_from_cache('analytics_' + setup.position_signature))
    else
      turn = analytics_params[:turn] == 'w' ? 'white' : 'black'
      possible_moves = game_move_logic.find_next_moves(deserialized_pieces, turn, notation)
      analyzed_moves = analyze_moves(possible_moves)
      serialized_moves = AnalyticsSerializer.serialize(analyzed_moves, setup.outcomes)
      add_to_cache('analytics_' + setup.position_signature, serialized_moves)
      serialized_moves
    end
  end

  def analyze_moves(possible_moves)
    ai_logic.move_analysis(possible_moves).map do |next_move, prediction|
      { move: next_move, evaluation: prediction }
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
end
