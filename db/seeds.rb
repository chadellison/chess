class Seeds
  def create_weights
    types = ['material', 'attack', 'activity', 'threat']
    win_values = ['white', 'black', 'draw']

    puts 'creating weights'

    types.each do |type|
      win_values.each do |win_value|
        Weight.create(weight_type: type, value: rand.to_s[0..5], win_value: win_value)
      end
    end

    puts '__________________________THE END__________________________'
  end
end

Seeds.new.create_weights
