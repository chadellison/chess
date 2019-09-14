class Weight < ApplicationRecord
  def self.initialize_weights
    Weight.destroy_all

    410.times do |count|
      Weight.create(weight_count: count + 1, value: rand)
    end
  end
end
