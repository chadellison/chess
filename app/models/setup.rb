class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  belongs_to :abstraction

  include OutcomeCalculator

  PIECE_PATTERNS = [ActivityLogic, AttackLogic, ThreatLogic]
  SETUP_PATTERNS = [CenterLogic, MaterialLogic, TempoLogic]

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
    patterns_by_piece = PIECE_PATTERNS.map do |pattern_class|
      game_data.piece_sets.map do |piece_set|
        pattern_class.create_signature(game_data, piece_set)
      end
    end

    patterns_by_setup = SETUP_PATTERNS.map do |pattern_class|
      pattern_class.create_signature(game_data)
    end
    pattern_signature = (patterns_by_piece + patterns_by_setup).join('.')
    Abstraction.find_or_create_by(pattern: pattern_signature)
  end
end
