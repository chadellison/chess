desc 'Train on stockfish'
task train_on_stockfish: :environment do
  ai_logic = AiLogic.new
  engine = ChessValidator::Engine
  # INDEX_KEY = {
  #  "a8" => 1,
  #  "b8" => 2,
  #  "c8" => 3,
  #  "d8" => 4,
  #  "e8" => 5,
  #  "f8" => 6,
  #  "g8" => 7,
  #  "h8" => 8,
  #  "a7" => 9,
  #  "b7" => 10,
  #  "c7" => 11,
  #  "d7" => 12,
  #  "e7" => 13,
  #  "f7" => 14,
  #  "g7" => 15,
  #  "h7" => 16,
  #  "a6" => 17,
  #  "b6" => 18,
  #  "c6" => 19,
  #  "d6" => 20,
  #  "e6" => 21,
  #  "f6" => 22,
  #  "g6" => 23,
  #  "h6" => 24,
  #  "a5" => 25,
  #  "b5" => 26,
  #  "c5" => 27,
  #  "d5" => 28,
  #  "e5" => 29,
  #  "f5" => 30,
  #  "g5" => 31,
  #  "h5" => 32,
  #  "a4" => 33,
  #  "b4" => 34,
  #  "c4" => 35,
  #  "d4" => 36,
  #  "e4" => 37,
  #  "f4" => 38,
  #  "g4" => 39,
  #  "h4" => 40,
  #  "a3" => 41,
  #  "b3" => 42,
  #  "c3" => 43,
  #  "d3" => 44,
  #  "e3" => 45,
  #  "f3" => 46,
  #  "g3" => 47,
  #  "h3" => 48,
  #  "a2" => 49,
  #  "b2" => 50,
  #  "c2" => 51,
  #  "d2" => 52,
  #  "e2" => 53,
  #  "f2" => 54,
  #  "g2" => 55,
  #  "h2" => 56,
  #  "a1" => 57,
  #  "b1" => 58,
  #  "c1" => 59,
  #  "d1" => 60,
  #  "e1" => 61,
  #  "f1" => 62,
  #  "g1" => 63,
  #  "h1" => 64
  # }

  ENV['COUNT'].to_i.times do |game_number|
    start_time = Time.now
    game_over = false
    positions = []
    stockfish_turn = ['w', 'b'].sample
    fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
    stockfish = Stockfish::Engine.new

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
      puts '-------------------------------------'

      outcome = engine.result(fen_notation)
      if outcome.present?
        positions.each do |position|
          ResultHelper.update_results(position, outcome)
        end
        game_over = true
        puts "FINISHED GAME IN #{Time.at(Time.now - start_time).utc.strftime("%H:%M:%S")}!"
        puts "OUTCOME:  #{outcome}"
        puts '---------------THE END---------------'
      end
    end
  end
end
