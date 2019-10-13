class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  has_many :setup_abstractions
  has_many :abstractions, through: :setup_abstractions

  include OutcomeCalculator

  def self.find_setup(game_data)
    signature = Signature.create_signature(game_data.pieces, game_data.turn[0])
    setup = Setup.find_by(position_signature: signature)
    return setup if setup.present?

    setup = Setup.new(position_signature: signature)
    setup.abstractions = create_abstractions(game_data)
    setup
  end

  def self.create_abstractions(game_data)
    # pattern_signature = [
      # ActivityLogic.activity_pattern(game_data),
      # create_signature(AttackLogic.attack_pattern(game_data), game_data.turn[0]),
      # AttackLogic.threat_pattern(game_data),
      # AttackLogic.threatened_attacker_pattern(game_data),
      # CenterLogic.center_control_pattern(game_data),
      # DefenseLogic.ally_defense_pattern(game_data),
      # DefenseLogic.opponent_defense_pattern(game_data),
      # DevelopmentLogic.development_pattern(game_data),
      # MaterialLogic.material_pattern(game_data),
      # KingThreatLogic.king_threat_pattern(game_data),
      # TempoLogic.create_signature(game_data),
      # ThreatLogic.create_signature(game_data)
    # ]
    [
      Abstraction.find_or_create_by(
        abstraction_type: 'attack',
        pattern: AttackLogic.find_pattern(game_data)
      ),
      Abstraction.find_or_create_by(
        abstraction_type: 'king_threat',
        pattern: KingThreatLogic.find_pattern(game_data)
      ),
    ]
  end
end
