class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature
  belongs_to :attack_signature, optional: true
  belongs_to :general_attack_signature, optional: true
  belongs_to :material_signature, optional: true
  belongs_to :threat_signature, optional: true

  def add_signatures(new_pieces, game_turn_code)
    [
      AttackSignature,
      ThreatSignature,
      MaterialSignature,
      GeneralAttackSignature
    ].each do |signature_class|
      signature = signature_class.create_signature(new_pieces, game_turn_code)

      if signature.present?
        signature_class.find_or_create_by(signature: signature).setups << self
      end
    end

    save
  end
end
