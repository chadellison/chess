class Abstraction < ApplicationRecord
  validates_uniqueness_of :pattern
  has_many :setups
end
