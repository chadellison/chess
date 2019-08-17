class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature

  belongs_to :abstraction
  has_many :setup_signatures
  has_many :signatures, through: :setup_signatures

  include OutcomeCalculator

  PATTERNS = [
    ActivityLogic,
    AttackLogic,
    MaterialLogic,
    TempoLogic,
    ThreatLogic
  ]

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
    piece_sets = [
      game_data.pawns,
      game_data.knights,
      game_data.bishops,
      game_data.rooks,
      game_data.queens,
      game_data.kings
    ]
    pattern_signature = PATTERNS.map do |pattern_class|
      piece_sets.map do |piece_set|
        pattern_class.create_signature(game_data, piece_set)
      end.join('.')
    end.join('.')

    Abstraction.find_or_create_by(pattern: pattern_signature)
  end
end
