class Move < ApplicationRecord
  belongs_to :game
  belongs_to :setup, optional: true

  attr_accessor :material_value
end
