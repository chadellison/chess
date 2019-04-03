desc 'Train'
task train_with_setups: :environment do
  count = 0
  while true
    neural_network = NeuralNetwork.new

    setup = Setup.where.not(outcome: {}).order('RANDOM()').first

    game_turn = setup.position_signature[-1] == 'w' ? 'white' : 'black'
    neural_network.propagate_results(setup)
    count += 1
    puts 'COUNT: ' + count.to_s
  end
end
