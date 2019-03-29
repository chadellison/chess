class AiLogic
  include CacheLogic

  attr_reader :game

  def initialize(game)
    @game = game
  end

  def neural_network
    @neural_network ||= NeuralNetwork.new
  end

  def ai_move(game_turn)
    possible_moves = find_next_moves(game_turn)

    if find_checkmate(possible_moves, game_turn).present?
      checkmate_opponent(possible_moves, game_turn)
    else
      weighted_moves = neural_network.move_analysis(possible_moves, game_turn)
      best_move_value = find_best_move(weighted_moves)
      game.handle_move(best_move_value, promote_pawn(best_move_value))
    end
  end

  def find_best_move(weighted_moves)
    weighted_moves.max_by { |move_value, weight| weight }.first
  end

  def find_next_moves(game_turn)
    setup_key = game.last_move.present? ? game.last_move.setup_id : 'initial_setup'
    if in_cache?(setup_key)
      get_next_moves_from_cache(setup_key)
    else
      opponent_color_code = game_turn == 'white' ? 'b' : 'w'
      next_moves = game.pieces.select { |piece| piece.color == game_turn }.map do |piece|
        all_next_moves_for_piece(piece, opponent_color_code)
      end.flatten
      add_to_cache(setup_key, next_moves)
      next_moves
    end
  end

  def all_next_moves_for_piece(piece, opponent_color_code)
    move_count = game.moves.size + 1

    piece.valid_moves(game.pieces).map do |move|
      move_value = piece.position_index.to_s + move
      game_move = Move.new(value: move_value, move_count: move_count)
      game_pieces = Game.pieces_with_next_move(game.pieces, move_value)
      game_move.setup = Setup.create_setup(game_pieces, opponent_color_code)
      game_move
    end
  end

  def checkmate_opponent(possible_moves, game_turn)
    best_move = find_checkmate(possible_moves, game_turn)
    game.handle_move(best_move.value, promote_pawn(best_move.value))
  end

  def find_checkmate(possible_moves, game_turn)
    opponent_color = game_turn == 'white' ? 'black' : 'white'
    possible_moves.detect do |next_move|
      game_pieces = Game.pieces_with_next_move(game.pieces, next_move.value)
      game.checkmate?(game_pieces, opponent_color)
    end
  end

  def crossed_pawn?(move_value)
    (9..24).include?(move_value.to_i) &&
      (move_value[-1] == '1' || move_value[-1] == '8')
  end

  def promote_pawn(move_value)
    crossed_pawn?(move_value) ? 'queen' : ''
  end
end
