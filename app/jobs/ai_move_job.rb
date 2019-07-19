class AiMoveJob < ApplicationJob
  queue_as :default

  def perform(game)
    turn = game.current_turn
    possible_moves = game.game_move_logic.find_next_moves(game.pieces, turn, game.move_count)
    if game.find_checkmate(possible_moves, turn).present?
      move_value = game.find_checkmate(possible_moves, turn).value
    else
      move_value = game.ai_logic.ai_move(possible_moves, turn)
    end

    game.move(move_value.to_i, move_value[-2..-1], game.promote_pawn(move_value))
  end
end
