desc 'Train on self'
task train_on_self: :environment do
  ENV['COUNT'].to_i.times do
    game = Game.create
    start_time = Time.now

    game.machine_vs_machine

    if game.outcome.present? && game.outcome != 0
      game.moves.each do |move|
        move.setup.update(rank: (move.setup.rank + game.outcome))
      end
    end

    end_time = Time.now

    total_time = end_time - start_time

    puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
    puts "OUTCOME:  #{game.outcome}"
  end
  puts '---------------THE END---------------'
end
