class Seeds
  def create_initial_setup
    position_signature = Setup.create_signature(Game.new.pieces, 'w')
    setup = Setup.new(position_signature: position_signature)
    white_wins = Game.where(outcome: '1').count
    black_wins = Game.where(outcome: '0.5').count
    draws = Game.where(outcome: '0').count
    setup.outcomes = { white_wins: white_wins, black_wins: black_wins, draws: draws }
    setup.save
    puts 'created initial setup'
  end

  def create_weights
    Weight.destroy_all

    64.times do |count|
      Weight.create(weight_count: count + 1, value: rand.to_s)
    end
    puts 'created weights'
  end
end

seeds = Seeds.new
seeds.create_initial_setup
seeds.create_weights
puts '__________________________THE END__________________________'
