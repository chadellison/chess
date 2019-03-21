class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  SIGNATURES = {
    attack: AttackLogic,
    material: MaterialLogic,
    activity: ActivityLogic
  }

  include WeightCalculator

  def self.create_setup(new_pieces, opponent_color_code)
    game_signature = Setup.create_signature(new_pieces, opponent_color_code)
    setup = Setup.find_or_create_by(position_signature: game_signature)
    new_pieces.each { |piece| piece.valid_moves(new_pieces) }
    setup.add_signatures(new_pieces, opponent_color_code)
    setup
  end

  def self.create_signature(game_pieces, game_turn_code)
    game_pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.') + game_turn_code
  end

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
