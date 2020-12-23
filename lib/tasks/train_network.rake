desc 'Train'
task train_network: :environment do
  ai_logic = AiLogic.new
  # ai_logic.neural_network.set_weights([])
  # ai_logic.neural_network.initialize_weights

  REDIS.set('error_rate', { error: 0, count: 0 }.to_json)

  count = 0
  REDIS.hscan_each('positions') do |position_data|
    position = JSON.parse(position_data.last)

    if [position['white_wins'], position['black_wins'], position['draws']].any? { |value| value > 3 }
      turn = position['signature'].split[1]
      input = ai_logic.extract_inputs(position, turn)
      ai_logic.neural_network.train(input, [ai_logic.calculate_ratio(position, turn)])

      count += 1
      if count % 100 == 0
        error_object = JSON.parse(REDIS.get('error_rate')).symbolize_keys
        accuracy = ai_logic.neural_network.error
        puts 'ERROR: ********************' + accuracy.to_s
        REDIS.set('error_rate', { error: 0, count: 0 }.to_json)
      end
      if count % 10000 == 0
        ai_logic.neural_network.save_weights("#{Rails.root}/json/weights.json")
      end
    end
  end
  ai_logic.neural_network.save_weights("#{Rails.root}/json/weights.json")
end
