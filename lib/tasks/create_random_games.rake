desc 'Create random games'
task create_random_games: :environment do
  ai_logic = AiLogic.new

  ENV['COUNT'].to_i.times do
    game = Game.create(analyzed: true)
    start_time = Time.now

    move_count = rand(10..50)
    until game.outcome.present? || game.move_count > move_count
      move_value = ai_logic.random_move(game)
      game.move(move_value.to_i, move_value[-2..-1], game.promote_pawn(move_value))
    end

    end_time = Time.now

    total_time = end_time - start_time

    puts "GAME STARTED IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
  end
  puts '---------------THE END---------------'
end
