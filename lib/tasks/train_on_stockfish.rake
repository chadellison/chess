desc 'Train on stockfish'
task train_on_stockfish: :environment do
  ai_logic = AiLogic.new

  ENV['COUNT'].to_i.times do |game_number|
    # game = Game.create(analyzed: true)
    openings = ['17a3', '20d4', '21e4', '31f3', '19c4', '23g4', '23g3', '24h3']
    random_opening = openings.sample
    # game.move(random_opening.to_i, random_opening[-2..-1])
    # stockfish = StockfishIntegration.new(game)
    # Stockfish.analyze fen, { :depth => 12 }
    game = Game.new
    start_time = Time.now

    until game.outcome.present? do
      turn = game.current_turn
      if turn == stockfish.stockfish_color(game_number)
        puts stockfish.fen_notation.find_fen_notation

        stockfish_move = stockfish.find_stockfish_move
        position_index = game.find_piece_by_position(stockfish_move[0..1]).position_index
        upgraded_type = stockfish.find_upgraded_type(stockfish_move[4])

        game.move(position_index, stockfish_move[2..3], upgraded_type)
      else
        move_value = ai_logic.random_move(game)
        game.move(move_value.to_i, move_value[-2..-1], game.promote_pawn(move_value))
      end
    end

    game.update_outcomes
    end_time = Time.now

    total_time = end_time - start_time

    puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
    puts "OUTCOME:  #{game.outcome}"
    puts '---------------THE END---------------'
  end
end
