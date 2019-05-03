desc 'Train'
task train_with_setups: :environment do
  count = 0
  neural_network = NeuralNetwork.new

  ENV['COUNT'].to_i.times do
    setup = Setup.where.not(outcome: {}).order('RANDOM()').first

    neural_network.train(setup)
    count += 1
    puts 'COUNT: ' + count.to_s
  end
end
