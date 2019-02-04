class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature
  belongs_to :material_signature, optional: true
  belongs_to :white_threat_signature, optional: true
  belongs_to :black_threat_signature, optional: true
  belongs_to :wpa_signature, optional: true
  belongs_to :bpa_signature, optional: true
  belongs_to :wna_signature, optional: true
  belongs_to :bna_signature, optional: true
  belongs_to :wba_signature, optional: true
  belongs_to :bba_signature, optional: true
  belongs_to :wra_signature, optional: true
  belongs_to :bra_signature, optional: true
  belongs_to :wqa_signature, optional: true
  belongs_to :bqa_signature, optional: true

  SIGNATURE_CLASSES = {
    material_signature: MaterialSignature,
    white_threat_signature: WhiteThreatSignature,
    black_threat_signature: BlackThreatSignature,
    wpa_signature: WpaSignature,
    bpa_signature: BpaSignature,
    wna_signature: WnaSignature,
    bna_signature: BnaSignature,
    wba_signature: WbaSignature,
    bba_signature: BbaSignature,
    wra_signature: WraSignature,
    bra_signature: BraSignature,
    wqa_signature: WqaSignature,
    bqa_signature: BqaSignature
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
    [material_signature, white_threat_signature, black_threat_signature,
      wpa_signature, bpa_signature, wna_signature, bna_signature, wba_signature,
      bba_signature, wra_signature, bra_signature, wqa_signature, bqa_signature]
  end
end
