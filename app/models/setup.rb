class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature

  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  SIGNATURES = [
    'material',
    'white_threat',
    'black_threat',
    'attack',
    'activity'
  ]

  def add_signatures(new_pieces, game_turn_code)
    SIGNATURES.each do |signature_type|
      if signatures.find_by(signature_type: signature_type).blank?
        signature = Signature.create_signature(signature_type, new_pieces, game_turn_code)
        signature.setups << self if signature.present?
      end
    end
  end
end
