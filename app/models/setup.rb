class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature
  belongs_to :general_attack_signature, optional: true
  belongs_to :material_signature, optional: true
  belongs_to :white_attack_signature, optional: true
  belongs_to :black_attack_signature, optional: true
  belongs_to :white_threat_signature, optional: true
  belongs_to :black_threat_signature, optional: true

  SIGNATURE_CLASSES = {
    general_attack_signature: GeneralAttackSignature,
    material_signature: MaterialSignature,
    white_attack_signature: WhiteAttackSignature,
    black_attack_signature: BlackAttackSignature,
    white_threat_signature: WhiteThreatSignature,
    black_threat_signature: BlackThreatSignature
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
    [general_attack_signature, material_signature, white_attack_signature,
      black_attack_signature, white_threat_signature, black_threat_signature]
  end
end
