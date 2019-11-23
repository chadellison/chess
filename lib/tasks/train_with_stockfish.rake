desc 'Train with stockfish'
task train_with_stockfish: :environment do
  play_stockfish
end

def ai_logic
  @ai_logic ||= AiLogic.new
end

def play_stockfish
  game = Game.create(analyzed: true)
  openings = ['17a3', '20d4', '21e4', '31f3', '19c4', '23g4', '23g3', '24h3']
  random_opening = openings.sample

  game.move(random_opening.to_i, random_opening[-2..-1])
  stockfish = StockfishIntegration.new(game)

  start_time = Time.now

  stockfish_color = stockfish.stockfish_color(rand(0..1))

  until game.outcome.present? do
    turn = game.current_turn

    if turn == stockfish_color
      puts stockfish.fen_notation.find_fen_notation

      stockfish_move = stockfish.find_stockfish_move
      position_index = game.find_piece_by_position(stockfish_move[0..1]).position_index
      upgraded_type = stockfish.find_upgraded_type(stockfish_move[4])

      game.move(position_index, stockfish_move[2..3], upgraded_type)
    else
      value = rand(10)
      if value < 8
        game.ai_move
      else
        move_value = ai_logic.random_move(game)
        game.move(move_value.to_i, move_value[-2..-1], game.promote_pawn(move_value))
      end
    end
  end

  game.update_outcomes
  end_time = Time.now

  total_time = end_time - start_time

  puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
  puts "OUTCOME: #{game.outcome}"
  train_network
  begin
    play_stockfish
  rescue
    play_stockfish
  end
end

def train_network
  neural_network = NeuralNetwork.new
  REDIS.set('error_rate', { error: 0, count: 0 }.to_json)

  setups = Setup.order('RANDOM()').limit(1000)
  count = 0
  setups.each do |setup|
    neural_network.train(setup.abstraction)

    error_object = JSON.parse(REDIS.get('error_rate')).symbolize_keys
    accuracy = error_object[:count] - error_object[:error]
    count += 1
    if count % 100 == 0
      puts 'ACCURACY: ********************' + (accuracy.to_f / error_object[:count].to_f).to_s
      REDIS.set('error_rate', { error: 0, count: 0 }.to_json)
      neural_network.save_weights
    end
  end
end
