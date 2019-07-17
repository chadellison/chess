class AiMoveJob < ApplicationJob
  queue_as :default

  def perform(game, current_turn)

    game.ai_logic.ai_move(current_turn)
    GameEventBroadcastJob.perform_later(game)
  end
end
