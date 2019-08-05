class Analytics
  attr_reader :neural_network, :game_move_logic
  include CacheLogic

  def initialize
    @neural_network = NeuralNetwork.new
    @game_move_logic = GameMoveLogic.new
  end

  def move_analytics(analytics_params)
    opponent_color_code = analytics_params[:turn] == 'w' ? 'b' : 'w'
    last_move = analytics_params[:moves].sort_by { |m| m[:move_count] }
    move = last_move.present? ? Move.new(value: last_move.last[:value]) : Move.new
    setup = find_setup(analytics_params[:pieces], opponent_color_code, move)
    if in_cache?('analytics_' + setup.position_signature)
      JSON.parse(get_from_cache('analytics_' + setup.position_signature))
    else
      game = load_game(analytics_params[:moves], setup)
      turn = analytics_params[:turn] == 'w' ? 'white' : 'black'
      move_count = analytics_params[:moves].count
      possible_moves = game_move_logic.find_next_moves(game.pieces, turn, move_count)
      analyzed_moves = analyzed_moves(possible_moves, turn)

      serialized_moves = AnalyticsSerializer.serialize(analyzed_moves)
      add_to_cache('analytics_' + setup.position_signature, serialized_moves)
      serialized_moves
    end
  end

  def analyzed_moves(possible_moves, turn)
    neural_network.move_analysis(possible_moves, turn).map do |next_move, prediction|
      { move: next_move, white: prediction, black: prediction * -1 }
    end
  end

  def find_setup(pieces, turn_code, last_move)
    formatted_pieces = dersialize_pieces(pieces)
    Setup.find_setup(formatted_pieces, turn_code, Move.new)
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

  def load_game(moves, setup)
    game = Game.new
    game.moves = dersialize_moves(moves)

    if game.moves.blank?
      game.pieces
    else
      game.last_move.setup = setup
    end
    game
  end
end
