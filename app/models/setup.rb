class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature
  belongs_to :attack_signature, optional: true
  belongs_to :general_attack_signature, optional: true
  belongs_to :material_signature, optional: true
  belongs_to :threat_signature, optional: true

  SIGNATURE_CLASSES = {
    attack_signature: AttackSignature,
    threat_signature: ThreatSignature,
    material_signature: MaterialSignature,
    general_attack_signature: GeneralAttackSignature
  }

  def add_signatures(new_pieces, game_turn_code)
    SIGNATURE_CLASSES.each do |signature_key, signature_class|
      if send(signature_key).blank?
        signature = signature_class.create_signature(new_pieces, game_turn_code)
        signature_class.find_or_create_by(signature: signature).setups << self if signature.present?
      end
    end
  end

  def all_signatures
    [material_signature, threat_signature, attack_signature, general_attack_signature]
  end
end
