class BpaSignature < ApplicationRecord
  validates_presence_of :signature
  validates_uniqueness_of :signature
  has_many :setups

  def self.create_signature(new_pieces, game_turn_code)
    AttackLogic.create_attack_signature(new_pieces, (9..16).to_a)
  end
end
