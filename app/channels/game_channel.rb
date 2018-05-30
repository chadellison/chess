class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_id]}"
  end

  def unsubscribed
    game = Game.find(params['game_id'])
    game.destroy if game.status == 'awaiting player' || game.game_type.include?('machine')
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
