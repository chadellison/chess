desc 'Finish random games'
task finish_random_games: :environment do
  finish_game
  puts '---------------THE END---------------'
end

def finish_game
  game = Game.where(outcome: nil).order('RANDOM()').first
  if game.present?
    stockfish = StockfishIntegration.new(game)

    start_time = Time.now

    until game.outcome.present?
      stockfish_move = stockfish.find_stockfish_move
      position_index = game.find_piece_by_position(stockfish_move[0..1]).position_index
      upgraded_type = stockfish.find_upgraded_type(stockfish_move[4])

      game.move(position_index, stockfish_move[2..3], upgraded_type)
    end

    game.update_outcomes

    end_time = Time.now

    total_time = end_time - start_time

    puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
    puts "OUTCOME:  #{game.outcome}"
    finish_game
  else
    puts 'NO UNFINISHED GAMES'
  end
end
