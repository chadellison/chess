desc 'Train on stockfish'
task train_on_stockfish: :environment do
  engine = ChessValidator::Engine
  stockfish = Stockfish::Engine.new

  ENV['COUNT'].to_i.times do |game_number|
    start_time = Time.now
    game_over = false
    positions = []
    stockfish_turn = ['w', 'b'].sample
    fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

    until game_over do
      if fen_notation.split[1] == stockfish_turn

        stockfish_result = stockfish.analyze(fen_notation, { :depth => 8 })
        best_move = stockfish_result.split('bestmove').last.split('ponder').first.strip

        board = ChessValidator::BoardLogic.build_board(PGN::FEN.new(fen_notation))
        piece = board[INDEX_KEY[best_move[0..1]]]
        move = best_move[2..3]
        fen_notation = engine.move(piece, move, fen_notation)
      else
        pieces_with_moves = engine.find_next_moves(fen_notation)
        fen_notation = engine.make_random_move(fen_notation, pieces_with_moves)
      end

      positions << Position.create_position(fen_notation)
      puts PGN::FEN.new(fen_notation).board.inspect
      puts fen_notation
      puts '-------------------------------------'

      outcome = engine.result(fen_notation)
      if outcome.present?
        positions.each do |position|
          ResultHelper.update_results(position, outcome)
          CacheService.hset('positions', position['signature'], position)
        end
        positions = []
        game_over = true
        puts "FINISHED GAME IN #{Time.at(Time.now - start_time).utc.strftime("%H:%M:%S")}!"
        puts "OUTCOME:  #{outcome}"
        puts '---------------THE END---------------'
      end
    end
  end
end
