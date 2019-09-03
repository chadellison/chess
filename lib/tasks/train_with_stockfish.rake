desc 'Train with stockfish'
task train_with_stockfish: :environment do
  play_stockfish
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
      game.ai_move
    end
  end

  game.update_outcomes
  end_time = Time.now

  total_time = end_time - start_time

  puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
  puts "OUTCOME: #{game.outcome}"
  train_network
  play_stockfish
end

def train_network
  neural_network = NeuralNetwork.new
  REDIS.set('error_rate', { error: 0, count: 0 }.to_json)

  abstractions = Abstraction.order('RANDOM()').limit(1000)
  abstractions.each do |abstraction|
    neural_network.train(abstraction)
    # puts 'COUNT: ' + count.to_s

    error_object = JSON.parse(REDIS.get('error_rate')).symbolize_keys
    accuracy = error_object[:count] - error_object[:error]
    puts 'ACCURACY: ********************' + (accuracy.to_f / error_object[:count].to_f).to_s
  end
end
