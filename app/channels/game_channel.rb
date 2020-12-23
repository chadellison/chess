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
    if opts['game_id'] == 'default'
      game = Game.new
    else
      game = Game.find(opts['game_id'])
    end
    game.move(opts['notation'])
  end
end
