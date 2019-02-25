class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature

  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  SIGNATURES = {
    threat: ThreatLogic,
    attack: AttackLogic,
    activity: ActivityLogic
  }

  def add_signatures(new_pieces, game_turn_code)
    SIGNATURES.each do |signature_type, signature_class|
      if signatures.find_by(signature_type: signature_type.to_s).blank?
        signature_value = signature_class.create_signature(new_pieces)
        handle_signature(signature_type.to_s, signature_value, game_turn_code)
      end
    end
  end

  def handle_signature(signature_type, signature_value, game_turn_code)
    if signature_value.present?
      signature = Signature.where(
        signature_type: signature_type,
        value: signature_value + game_turn_code
      ).first_or_create

      signature.setups << self if signature.present?
    end
  end
end
