class CacheService
  def self.hget(type, key)
    json = REDIS.hget(type, key)
    if json.present?
      JSON.parse(json)
    end
  end

  def self.hset(type, key, value)
    REDIS.hset(type, key, value.to_json)
  end

  def self.flushall
    REDIS.flushall
  end
end
