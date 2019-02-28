module CacheLogic
  extend ActiveSupport::Concern

  def in_cache?(notation)
    REDIS.get(notation).present?
  end

  def get_move(notation)
    Move.new(JSON.parse(REDIS.get(notation)))
  end

  def cache_move(move_key, game_move)
    REDIS.set(move_key, game_move.to_json)
    REDIS.expire(move_key, 5.hour.to_i)
  end

  def update_game_from_cache(notation)
    puts 'YAYAAYAY WE ARE USING THE CACHE+++++++++++++++++++++++++'
    game_move = get_move(notation)
    moves << game_move
    game_move.save
    reload_pieces
  end
end
