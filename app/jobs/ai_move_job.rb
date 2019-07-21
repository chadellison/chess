class AiMoveJob < ApplicationJob
  queue_as :default

  def perform(game)
    game.ai_move
  end
end
