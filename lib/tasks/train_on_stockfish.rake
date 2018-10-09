desc 'Train on stockfish'
task train_on_stockfish: :environment do
  ENV['COUNT'].to_i.times do |game_number|
    game = Game.create
    stockfish_integration = StockfishIntegration.new(game)

    start_time = Time.now

    until game.outcome.present? do
      turn = game.current_turn

      if turn == stockfish_integration.stockfish_color(game_number)
        puts stockfish_integration.find_fen_notation

        stockfish_move = stockfish_integration.find_stockfish_move
        position_index = stockfish_integration.find_piece_index(stockfish_move)
        upgraded_type = stockfish_integration.find_upgraded_type(stockfish_move[4])

        game.move(position_index, stockfish_move[2..3], upgraded_type)
      else
        game.ai_move
      end
    end

    end_time = Time.now

    total_time = end_time - start_time

    puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
    puts "OUTCOME:  #{game.outcome}"
    puts '---------------THE END---------------'
  end
end
