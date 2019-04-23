class Seeds
  def create_weights
    Weight.destroy_all

    56.times do |count|
      multiplyer = rand < 0.5 ? -1 : 1
      weight_value = (rand * multiplyer).to_s
      Weight.create(weight_count: count + 1, value: weight_value)
    end
    puts 'created weights'
  end
end

seeds = Seeds.new
seeds.create_weights
puts '__________________________THE END__________________________'
