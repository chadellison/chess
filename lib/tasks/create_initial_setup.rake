desc "create_initial_setup"
task create_initial_setup: :environment do
  setup = Setup.save_setup_and_signatures(Game.new.pieces, 'b')
  white_wins = Game.where(outcome: '1').count
  black_wins = Game.where(outcome: '0.5').count
  draws = Game.where(outcome: '0').count
  setup.outcomes = { white_wins: white_wins, black_wins: black_wins, draws: draws }
  setup.save
  puts 'created initial setup'
end
