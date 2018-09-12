class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature
  belongs_to :attack_signature, optional: true
  belongs_to :material_signature, optional: true
end
