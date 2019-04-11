desc 'Train on self'
task train_on_self: :environment do
  neural_network = NeuralNetwork.new

  ENV['COUNT'].to_i.times do
    game = Game.create(analyzed: true)
    start_time = Time.now

    game.machine_vs_machine

    game.update_outcomes

    end_time = Time.now

    total_time = end_time - start_time

    puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
    puts "OUTCOME:  #{game.outcome}"
  end
  puts '---------------THE END---------------'
end
