desc 'Train'
task train_with_setups: :environment do
  neural_network = NeuralNetwork.new
  REDIS.set('error_rate', { error: 0, count: 0 }.to_json)

  ENV['COUNT'].to_i.times do |count|
    setup = Move.where('move_count > ?', 4).order('RANDOM()').first.setup

    neural_network.train(setup)
    puts 'COUNT: ' + count.to_s

    if count % 100 == 0
      error_object = JSON.parse(REDIS.get('error_rate')).symbolize_keys
      puts 'ERROR RATE: ********************' + (error_object[:error] / error_object[:count]).to_s
    end
  end
end
