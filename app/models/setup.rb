class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  belongs_to :abstraction

  include OutcomeCalculator

  def self.find_setup(game_data)
    signature = Setup.create_signature(game_data.pieces, game_data.turn[0])
    setup = Setup.find_by(position_signature: signature)
    return setup if setup.present?

    setup = Setup.new(position_signature: signature)
    setup.abstraction = create_abstraction(game_data)
    setup
  end

  def self.create_signature(game_pieces, game_turn_code)
    game_pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.') + game_turn_code
  end

  def self.create_abstraction(game_data)
    pattern_signature = [
      ActivityLogic.activity_pattern(game_data),
      AttackLogic.attack_pattern(game_data),
      AttackLogic.threat_pattern(game_data),
      AttackLogic.threatened_attacker_pattern(game_data),
      CenterLogic.center_control_pattern(game_data),
      DefenseLogic.ally_defense_pattern(game_data),
      DefenseLogic.opponent_defense_pattern(game_data),
      DefenseLogic.general_defense_pattern(game_data),
      DiagonalLogic.ally_diagonal_pattern(game_data),
      DiagonalLogic.opponent_diagonal_pattern(game_data),
      DevelopmentLogic.development_pattern(game_data),
      MaterialLogic.material_pattern(game_data),
      PinLogic.pin_pattern(game_data),
      KingThreatLogic.king_threat_pattern(game_data),
      TempoLogic.tempo_pattern(game_data),
    ]
    Abstraction.find_or_create_by(pattern: pattern_signature.join('-'))
  end
end
