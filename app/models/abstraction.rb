class Abstraction < ApplicationRecord
  serialize :outcomes, Hash
  validates :pattern, uniqueness: { scope: :abstraction_type }
  has_many :setup_abstractions
  has_many :setups, through: :setup_abstractions

  include OutcomeCalculator
end
