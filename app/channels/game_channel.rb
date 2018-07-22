class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_id]}"
  end

  def unsubscribed
    game = Game.find(params['game_id'])

    should_destroy_game = [
      game.status == 'awaiting player',
      game.outcome.present? && game.game_type != 'machine vs machine'
    ].any?

    game.destroy if should_destroy_game
  end

  def update(opts)
    game = Game.find(opts['game_id'])
    game.move(opts['position_index'], opts['new_position'], opts['upgraded_type'])
  end

  def ai_move(opts)
    game = Game.find(opts['game_id'])
    game.ai_move
  end
end
