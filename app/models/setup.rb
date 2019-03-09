class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  SIGNATURES = { attack: AttackLogic }

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

  def rank
    outcomes[:white_wins].to_i - outcomes[:black_wins].to_i
  end

  def average_outcome
    return 0 if rank == 0
    rank / (outcomes[:white_wins].to_f + outcomes[:black_wins].to_f + outcomes[:draws].to_f)
  end

  def update_outcomes(outcome)
    key = { 1 => :white_wins, -1 => :black_wins, 0 => :draws }[outcome]

    if outcomes[key].present?
      outcomes[key] += 1
    else
      outcomes[key] = 1
    end
    save
  end
end
