desc 'Train'
task train_with_abstractions: :environment do
  ai_logic = AiLogic.new
  ai_logic.neural_network.set_weights([])
  ai_logic.neural_network.initialize_weights

  REDIS.set('error_rate', { error: 0, count: 0 }.to_json)

  count = 0
  Abstraction.find_each do |abstraction|
    input = ai_logic.normalize_values(abstraction)
    target_output = ai_logic.softmax(ai_logic.calculate_outcomes(abstraction))
    ai_logic.neural_network.train(input, target_output)

    count += 1
    if count % 100 == 0
      error_object = JSON.parse(REDIS.get('error_rate')).symbolize_keys
      accuracy = ai_logic.neural_network.error
      puts 'ERROR: ********************' + accuracy.to_s
      REDIS.set('error_rate', { error: 0, count: 0 }.to_json)
    end
  end
  ai_logic.neural_network.save_weights("#{Rails.root}/json/weights.json")
end
