desc 'Train'
task train_with_abstractions: :environment do
  neural_network = NeuralNetwork.new
  REDIS.set('error_rate', { error: 0, count: 0 }.to_json)

  neural_network.load_training_data(ENV['COUNT'].to_i)
  neural_network.train(27, [30, 20, 3], 1)
  # count = 0
  # 100.times do
  #   abstractions = Abstraction.order('RANDOM()').limit(ENV['COUNT'].to_i)
  #   abstractions.each do |abstraction|
      # neural_network.train(ENV['COUNT'].to_i)
      # count += 1

      # if count % 100 == 0
      #   error_object = JSON.parse(REDIS.get('error_rate')).symbolize_keys
      #   accuracy = error_object[:count] - error_object[:error]
      #   puts 'ACCURACY: ********************' + (accuracy.to_f / error_object[:count].to_f).to_s
      #   neural_network.save_weights
      # end
  #   end
  # end
end
