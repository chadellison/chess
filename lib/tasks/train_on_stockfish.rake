desc 'Train on stockfish'
task train_on_stockfish: :environment do
  neural_network = NeuralNetwork.new

  range = 0..ENV['COUNT'].to_i

  Parallel.each(range) do |game_number|
    game = Game.create(analyzed: true)
    openings = ['17a3', '20d4', '21e4', '31f3', '19c4', '23g4', '23g3', '24h3']
    random_opening = openings.sample
    game.move(random_opening.to_i, random_opening[-2..-1])
    stockfish = StockfishIntegration.new(game)

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
        make_random_move(game, turn)
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

def make_random_move(game, turn)
  game_pieces = game.pieces.select { |piece| piece.color == turn }
  game_moves = game_pieces.map do |piece|
    piece.valid_moves.map { |move| piece.position_index.to_s + move }
  end.flatten

  move_value = game_moves.sample

  game.move(move_value.to_i, move_value[-2..-1], game.promote_pawn(move_value))
end
