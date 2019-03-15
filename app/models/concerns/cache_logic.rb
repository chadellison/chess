module CacheLogic
  extend ActiveSupport::Concern

  def in_cache?(key)
    REDIS.get(key).present?
  end

  def get_next_moves_from_cache(setup_id)
    JSON.parse(REDIS.get(setup_id)).map { |move| Move.new(move) }
  end

  def get_move(notation)
    Move.new(JSON.parse(REDIS.get(notation)))
  end

  def add_to_cache(key, value)
    REDIS.set(key, value.to_json)
    REDIS.expire(key, 1.day.to_i)
  end

  def update_game_from_cache(notation, r)
    puts 'YAYAAYAY WE ARE USING THE CACHE+++++++++++++++++++++++++'
    game_move = Move.new(r['data'])
    moves << game_move
    game_move.save
    reload_pieces
  end
end
