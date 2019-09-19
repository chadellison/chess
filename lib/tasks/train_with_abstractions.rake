desc 'Train'
task train_with_abstractions: :environment do
  neural_network = NeuralNetwork.new
  REDIS.set('error_rate', { error: 0, count: 0 }.to_json)

  random = false

  abstractions = []
  count_var = ENV['COUNT']

  if count_var != nil || count_var != ''
    abstractions = Abstraction.order('RANDOM()').limit(count_var.to_i)
  else
    abstractions = Abstraction.all
  end

  if random
    100.times do
      train(neural_network, abstractions)
    end
  else
    train(neural_network, abstractions)
  end
end

def train(neural_network, abstractions)
  abstractions.each_with_index do |abstraction, idx|
    neural_network.train(abstraction)

    if idx % 100 == 0
      error_object = JSON.parse(REDIS.get('error_rate')).symbolize_keys
      accuracy = error_object[:count] - error_object[:error]
      puts 'ACCURACY: ' + (accuracy.to_f / error_object[:count].to_f).to_s
      neural_network.save_weights
    end
  end
end
