class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  SIGNATURES = {
    activity: ActivityLogic,
    attack: AttackLogic,
    material: MaterialLogic,
    tempo: TempoLogic,
    controlled_space: ControlledSpaceLogic,
    threat: ThreatLogic
  }

  include OutcomeCalculator

  def self.find_setup(new_pieces, opponent_color_code)
    game_signature = Setup.create_signature(new_pieces, opponent_color_code)
    setup = Setup.find_by(position_signature: game_signature)
    return setup if setup.present?

    setup = Setup.new(position_signature: game_signature)
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
      signature_value = signature_class.create_signature(new_pieces, game_turn_code)
      handle_signature(signature_type.to_s, signature_value)
    end
  end

  def handle_signature(signature_type, signature_value)
    signature = Signature.find_by(
      signature_type: signature_type,
      value: signature_value
    )

    if signature.blank?
      signature = Signature.new(signature_type: signature_type, value: signature_value)
    end

    self.signatures << signature
  end
end
