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
    # checkmate: CheckmateLogic,
    # king: KingLogic,
    knight: KnightLogic,
    material: MaterialLogic,
    pawn: PawnLogic,
    queen: QueenLogic,
    rook: RookLogic,
    tempo: TempoLogic
    # threat: ThreatLogic
  }

  def self.find_setup(new_pieces, opponent_color_code, move)
    game_signature = Setup.create_signature(new_pieces, opponent_color_code)
    setup = Setup.find_by(position_signature: game_signature)
    return setup if setup.present?

    setup = Setup.new(position_signature: game_signature)
    setup.add_signatures(new_pieces, opponent_color_code, move)
    setup
  end

  def self.create_signature(game_pieces, game_turn_code)
    game_pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.') + game_turn_code
  end

  def add_signatures(new_pieces, game_turn_code, move)
    setup_data = SetupData.new(new_pieces, game_turn_code, move)

    SIGNATURES.each do |signature_type, signature_class|
      signature_value = signature_class.create_signature(setup_data)
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
