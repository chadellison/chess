desc 'load setups into redis'
task load_setups_into_redis: :environment do
  Setup.find_each do |setup|
    outcome = setup.find_outcome
    REDIS.set('eval_' + setup.position_signature, outcome)
    puts 'loaded: ' + outcome.to_s
  end
end
