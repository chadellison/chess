desc 'Train on stockfish'
task train_on_stockfish: :environment do
  ai_logic = AiLogic.new
  engine = ChessValidator::Engine

  ENV['COUNT'].to_i.times do |game_number|
    start_time = Time.now
    game_over = false
    positions = []
    stockfish_turn = ['w', 'b'].sample
    fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

    until game_over do
      pieces_with_moves = engine.find_next_moves(fen_notation)

      if fen_notation.split[1] == stockfish_turn
        stockfish_result = Stockfish.analyze fen_notation, { :depth => 8 }
        binding.pry if stockfish_result[:bestmove].size != 4
        piece_position = stockfish_result[:bestmove][0..1]

        piece = pieces_with_moves.detect { |p| p.position = piece_position }
        move = stockfish_result[:bestmove][2..3]
      else
        piece = pieces_with_moves.sample
        move = piece.valid_moves.sample
      end
      fen_notation = engine.move(piece, move, fen_notation)
      positions << Position.create_position(fen_notation)

      puts fen_notation

      outcome = ChessValidator::GameLogic.find_game_result(fen_notation)
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
