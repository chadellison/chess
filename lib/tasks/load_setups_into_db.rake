desc "load_setups_into_db"
task load_setups_into_db: :environment do
  Setup.destroy_all
  Abstraction.destroy_all
  REDIS.keys('setup_*').each do |key|
    setup = SetupSerializer.deserialize(REDIS.get(key))
    setup.abstractions.each do |abs|
      update_abstraction_outcomes(abs, :white_wins, setup.outcomes[:white_wins].to_f)
      update_abstraction_outcomes(abs, :black_wins, setup.outcomes[:black_wins].to_f)
      update_abstraction_outcomes(abs, :draws, setup.outcomes[:draws].to_f)
    end
    puts setup.position_signature + ' saved!'
    setup.save(validate: false)
  end
end

def update_abstraction_outcomes(abstraction, type, outcomes)
  if abstraction.outcomes[type].present?
    abstraction.outcomes[type].to_f += outcomes
  else
    abstraction.outcomes[type] = outcomes
  end
end
