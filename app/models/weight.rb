class Weight < ApplicationRecord
  def self.initialize_weights
    Weight.destroy_all

    69.times { |count| Weight.create(weight_count: count + 1, value: rand) }
  end
end
