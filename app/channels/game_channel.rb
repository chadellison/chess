class GameChannel < ApplicationCable::Channel

  PROMOTE_CLASS = {
    'knight' => Knight, 'bishop' => Bishop, 'rook' => Rook, 'queen' => Queen
  }

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
    promoted_class = PROMOTE_CLASS[opts['upgraded_type']]
    game.move(opts['position_index'], opts['new_position'], promoted_class)
  end

  def ai_move(opts)
    game = Game.find(opts['game_id'])
    game.ai_move
  end
end
