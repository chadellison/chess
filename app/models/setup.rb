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
      ActivityLogic.create_signature(game_data),
      AttackLogic.create_signature(game_data),
      CenterLogic.create_signature(game_data),
      DevelopmentLogic.create_signature(game_data),
      MaterialLogic.create_signature(game_data),
      TempoLogic.create_signature(game_data),
      ThreatLogic.create_signature(game_data)
    ].join('-')
    Abstraction.find_or_create_by(pattern: pattern_signature)
  end
end
