class Seeds
  def create_weights
    Weight.destroy_all

    64.times do |count|
      Weight.create(weight_count: count + 1, value: rand.to_s)
    end
    puts 'created weights'
  end
end

seeds = Seeds.new
seeds.create_weights
puts '__________________________THE END__________________________'
