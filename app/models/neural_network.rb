class NeuralNetwork
  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    possible_moves.shuffle.each do |possible_move|
      setup = possible_move.setup
      total_weight = setup.signatures.reduce(setup.average_outcome) do |weight, signature|
        log_move_data(game_turn, signature, possible_move)
        weight + signature.average_outcome
      end

      total_weight *= -1 if game_turn == 'black'
      weighted_moves[possible_move.value] = total_weight
    end
    find_best_move(weighted_moves)
  end

  def log_move_data(game_turn, signature, possible_move)
    puts "TURN: #{game_turn}"
    puts "SIGNATURE TYPE #{signature.signature_type}"
    puts "SIGNATURE: #{signature.value}"
    puts "WEIGHT: #{possible_move.value} #{signature.rank.to_s}"
  end

  def find_best_move(weighted_moves)
    weighted_moves.max_by { |move_value, weight| weight }.first
  end
end
