desc 'Train on self'
task train_on_self: :environment do
  engine = ChessValidator::Engine

  ENV['COUNT'].to_i.times do |game_number|
    start_time = Time.now
    game_over = false
    positions = []
    fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

    until game_over do
      pieces_with_moves = engine.find_next_moves(fen_notation)
      fen_notation = engine.make_random_move(fen_notation, pieces_with_moves)

      positions << Position.create_position(fen_notation)
      puts PGN::FEN.new(fen_notation).board.inspect
      puts fen_notation

      outcome = engine.result(fen_notation)
      if outcome.present?
        positions.each do |position|
          Position.update_results(position, outcome)
          CacheService.hset('positions', position['signature'], position)
        end
        positions = []
        game_over = true
        puts "FINISHED GAME IN #{Time.at(Time.now - start_time).utc.strftime("%H:%M:%S")}!"
        puts "OUTCOME:  #{outcome}"
      end
    end
  end
  puts '---------------THE END---------------'
end
