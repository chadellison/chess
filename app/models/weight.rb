class Weight < ApplicationRecord
  def self.initialize_weights
    Weight.destroy_all

    45.times { |count| Weight.create(weight_count: count + 1, value: rand) }
    puts 'created weights'
  end
end
