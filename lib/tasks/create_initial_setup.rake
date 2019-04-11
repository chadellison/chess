desc "create_initial_setup"
task create_initial_setup: :environment do
  position_signature = Setup.create_signature(Game.new.pieces, 'w')
  setup = Setup.find_by(position_signature: position_signature)
  setup = Seupt.create(position_signature: position_signature) if setup.blank?
  white_wins = Game.where(outcome: '1').count
  black_wins = Game.where(outcome: '0.5').count
  draws = Game.where(outcome: '0').count
  setup.outcomes = { white_wins: white_wins, black_wins: black_wins, draws: draws }
  setup.save
  puts 'created initial setup'
end
