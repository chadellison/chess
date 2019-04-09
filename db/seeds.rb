class Seeds
  def create_weights
    Weight.destroy_all

    puts 'creating weights'

    24.times do |count|
      Weight.create(weight_count: count + 1, value: rand.to_s)
    end

    puts '__________________________THE END__________________________'
  end
end

Seeds.new.create_weights
