class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature
  belongs_to :abstraction

  include OutcomeCalculator
  include CacheLogic

  class << self
    def find_setup(game_data)
      signature = game_data.fen_data.board_string + game_data.fen_data.active
      key = 'setup_' + signature
      json_setup = get_from_cache(key)
      if json_setup.present?
        setup = SetupSerializer.deserialize(json_setup)
        return setup if setup.present?
      end

      setup = Setup.find_by(position_signature: signature)
      cache_setup(key, SetupSerializer.serialize(setup))
      return setup if setup.present?

      setup = Setup.new(position_signature: signature)
      setup.abstraction = create_abstraction(game_data)
      cache_setup(key, SetupSerializer.serialize(setup))
      setup
    end

    def create_abstraction(game_data)
      pattern_signature = [
        ActivityLogic.activity_pattern(game_data),
        AttackLogic.attack_pattern(game_data),
        AttackLogic.threat_pattern(game_data),
        AttackLogic.threatened_attacker_pattern(game_data),
        CenterLogic.center_control_pattern(game_data),
        DefenseLogic.ally_defense_pattern(game_data),
        DefenseLogic.opponent_defense_pattern(game_data),
        DevelopmentLogic.development_pattern(game_data),
        PinLogic.find_pattern(game_data),
        PawnStructureLogic.find_pattern(game_data),
        # MaterialLogic.material_pattern(game_data),
        KingThreatLogic.king_threat_pattern(game_data),
        PieceQualityLogic.find_pattern(game_data, 1),
        PieceQualityLogic.find_pattern(game_data, 2),
        PieceQualityLogic.find_pattern(game_data, 3),
        PieceQualityLogic.find_pattern(game_data, 4),
        PieceQualityLogic.find_pattern(game_data, 5),
        PieceQualityLogic.find_pattern(game_data, 6),
        PieceQualityLogic.find_pattern(game_data, 7),
        PieceQualityLogic.find_pattern(game_data, 8),
        PieceQualityLogic.find_pattern(game_data, 25),
        PieceQualityLogic.find_pattern(game_data, 26),
        PieceQualityLogic.find_pattern(game_data, 27),
        PieceQualityLogic.find_pattern(game_data, 28),
        PieceQualityLogic.find_pattern(game_data, 29),
        PieceQualityLogic.find_pattern(game_data, 30),
        PieceQualityLogic.find_pattern(game_data, 31),
        PieceQualityLogic.find_pattern(game_data, 32)
      ]
      Abstraction.find_or_create_by(pattern: pattern_signature.join(':'))
    end
  end
end
