class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  SIGNATURES = {
    attack: AttackLogic,
    material: MaterialLogic,
    activity: ActivityLogic,
    threat: ThreatLogic
  }

  include OutcomeCalculator

  def self.create_setup(new_pieces, opponent_color_code)
    game_signature = Setup.create_signature(new_pieces, opponent_color_code)
    # write this to redis instead...
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
        signature_value = signature_class.create_signature(new_pieces, game_turn_code)
        handle_signature(signature_type.to_s, signature_value)
      end
    end
  end

  def handle_signature(signature_type, signature_value)
    # write to redis
    # look and see if in the db--> if not. create new instance and write to redis
    signature = Signature.where(
      signature_type: signature_type,
      value: signature_value
    ).first_or_create

    signature.setups << self
  end

  def save_setup_and_signatures(new_pieces, game_turn_code)
    # this just needs to find or create by on each thing
    game_signature = Setup.create_signature(new_pieces, opponent_color_code)
    setup = Setup.find_or_create_by(position_signature: game_signature)
    # new_pieces.each { |piece| piece.valid_moves(new_pieces) }
    setup.add_signatures(new_pieces, opponent_color_code)
    setup
  end
end
