desc 'Train on stockfish'
task train_on_stockfish: :environment do
  neural_network = NeuralNetwork.new

  ENV['COUNT'].to_i.times do |game_number|
    game = Game.create(analyzed: true)
    openings = ['20d4', '21e4', '31f3', '19c4', '23g4']
    game.handle_move(openings.sample)
    stockfish = StockfishIntegration.new(game)

    start_time = Time.now
    ai_logic = AiLogic.new(game)

    until game.outcome.present? do
      turn = game.current_turn

      if turn == stockfish.stockfish_color(game_number)
        puts stockfish.fen_notation.find_fen_notation

        stockfish_move = stockfish.find_stockfish_move
        position_index = game.find_piece_by_position(stockfish_move[0..1]).position_index
        upgraded_type = stockfish.find_upgraded_type(stockfish_move[4])

        game.handle_move(position_index.to_s + stockfish_move[2..3], upgraded_type)
      else
        ai_logic.ai_move(turn)
      end
    end

    game.update_analytics
    end_time = Time.now

    total_time = end_time - start_time

    puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
    puts "OUTCOME:  #{game.outcome}"
    puts '---------------THE END---------------'
  end
end
