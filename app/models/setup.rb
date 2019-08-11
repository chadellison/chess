class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  include OutcomeCalculator

  SIGNATURES = {
    activity: ActivityLogic,
    attack: AttackLogic,
    bishop: BishopLogic,
    center: CenterLogic,
    knight: KnightLogic,
    material: MaterialLogic,
    pawn: PawnLogic,
    queen: QueenLogic,
    rook: RookLogic,
    tempo: TempoLogic
  }

  def self.find_setup(game_data)
    signature = Setup.create_signature(game_data.pieces, game_data.turn[0])
    setup = Setup.find_by(position_signature: signature)
    return setup if setup.present?

    setup = Setup.new(position_signature: signature)
    setup.add_signatures(game_data)
    setup
  end

  def self.create_signature(game_pieces, game_turn_code)
    game_pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.') + game_turn_code
  end

  def add_signatures(game_data)
    SIGNATURES.each do |signature_type, signature_class|
      signature_value = signature_class.create_signature(game_data)
      handle_signature(signature_type, signature_value)
    end
  end

  def handle_signature(signature_type, signature_value)
    signature = Signature.find_by(
      signature_type: signature_type,
      value: signature_value
    )
    if signature.blank?
      signature = Signature.create(signature_type: signature_type, value: signature_value)
    end

    self.signatures << signature
  end
end
