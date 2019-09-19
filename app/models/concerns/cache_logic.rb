module CacheLogic
  extend ActiveSupport::Concern

  def in_cache?(key)
    get_from_cache(key).present?
  end

  def get_from_cache(key)
    REDIS.get(key)
  end

  def get_move(notation)
    Move.new(JSON.parse(REDIS.get(notation)))
  end

  def add_to_cache(key, value)
    REDIS.set(key, value.to_json)
    REDIS.expire(key, 1.day.to_i)
  end
end
