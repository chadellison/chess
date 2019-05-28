desc 'Train on stockfish'
task train_on_stockfish: :environment do
  neural_network = NeuralNetwork.new

  ENV['COUNT'].to_i.times do |game_number|
    game = Game.create(analyzed: true)
    openings = ['17a3', '20d4', '21e4', '31f3', '19c4', '23g4', '23g3', '24h3']
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
        engine_move(game, ai_logic, turn)
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

def engine_move(game, ai_logic, turn)
  if rand > (ENV['RANDOMIZER'].to_i * 0.1)
    game_pieces = game.pieces.select { |piece| piece.color == turn }
    game_moves = game_pieces.map do |piece|
      piece.valid_moves.map { |move| piece.position_index.to_s + move }
    end.flatten

    random_move_value = game_moves.sample
    game.handle_move(random_move_value, ai_logic.promote_pawn(random_move_value))
  else
    ai_logic.ai_move(turn)
  end
end
