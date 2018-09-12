class MaterialSignature < ApplicationRecord
  validates_presence_of :signature
  validates_uniqueness_of :signature
  has_many :setups
end
