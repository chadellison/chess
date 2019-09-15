desc 'import weights'
task import_weights: :environment do
  puts 'DESTROYING GAMES'
  Game.destroy_all
  puts 'GAMES DESTROYED'

  puts 'DESTROYING SETUPS'
  Setup.destroy_all
  puts 'SETUPS DESTROYED'

  puts 'DESTROYING ABSTRACTIONS'
  Abstraction.destroy_all
  puts 'ABSTRACTIONS DESTROYED'

  puts 'DESTROYING WEIGHTS'
  Weight.destroy_all
  puts 'OLD WEIGHTS DESTROYED'

  puts 'FLUSHING REDIS'
  REDIS.flushall
  puts 'REDIS FLUSHED'

  json_weights = JSON.parse(File.read(Rails.root + 'json/weights.json'))
                    .map(&:symbolize_keys)

  json_weights.each do |json_weight|
    Weight.create(json_weight)
  end
  puts "INITIALIZED NEW WEIGHTS FROM 'json/weights.json'"
end
