class Signature < ApplicationRecord
  validates_presence_of :value, :signature_type
  validates :value, uniqueness: { scope: :signature_type }
  has_many :setup_signatures
  has_many :setups, through: :setup_signatures
end
