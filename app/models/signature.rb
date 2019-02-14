class Signature < ApplicationRecord
  validates_presence_of :value, :signature_type
  validates :value, uniqueness: { scope: :signature_type }
  has_many :setup_signatures
  has_many :setups, through: :setup_signatures

  def self.create_signature(type, new_pieces, game_turn_code)
    signature_value = write_signature(type, new_pieces)
    if signature_value.present?
      Signature.where(signature_type: type, value: signature_value + game_turn_code)
        .first_or_create
    end
  end

  def self.write_signature(type, new_pieces)
    case type
    when 'material'
      MaterialSignature.create_signature(new_pieces)
    when 'activity'
      ActivitySignature.create_signature(new_pieces)
    when 'white_threat'
      ThreatLogic.create_threat_signature(new_pieces, 'white')
    when 'black_threat'
      ThreatLogic.create_threat_signature(new_pieces, 'black')
    when 'attack'
      AttackLogic.create_attack_signature(new_pieces)
    end
  end
end
