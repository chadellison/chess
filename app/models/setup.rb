class Setup < ApplicationRecord
  serialize :outcomes, Hash
  validates_uniqueness_of :position_signature
  belongs_to :abstraction

  include OutcomeCalculator
  include CacheLogic

  class << self
    def find_setup(fen_data)
      signature = fen_data.board_string + fen_data.active
      key = 'setup_' + signature
      json_setup = get_from_cache(key)

      return Setup.new(JSON.parse(json_setup)) if json_setup.present?

      setup = Setup.find_by(position_signature: signature)
      add_to_cache(key, setup)
      return setup if setup.present?

      setup = Setup.new(position_signature: signature)
      setup.abstraction = create_abstraction(fen_data)
      add_to_cache(key, setup)
      setup
    end

    def create_abstraction(fen_data)
      pattern_signature = [0]
      # fen_data.board_string
      # get 1st through 6th + turn
      # get 2nd through 7th + turn
      # get 3rd through 8th + turn
      # 3 -- 6 + turn + castle data
      # 1,2 and 7,8 + turn + castle data
      # pattern for all attackers
      Abstraction.find_or_create_by(pattern: pattern_signature.join('-'))
    end
    # def create_abstraction(game_data)
    #   pattern_signature = [
    #     ActivityLogic.activity_pattern(game_data),
    #     AttackLogic.attack_pattern(game_data),
    #     AttackLogic.threat_pattern(game_data),
    #     AttackLogic.threatened_attacker_pattern(game_data),
    #     CenterLogic.center_control_pattern(game_data),
    #     DefenseLogic.ally_defense_pattern(game_data),
    #     DefenseLogic.opponent_defense_pattern(game_data),
    #     DevelopmentLogic.development_pattern(game_data),
    #     # MaterialLogic.material_pattern(game_data),
    #     0,
    #     KingThreatLogic.king_threat_pattern(game_data),
    #     # TempoLogic.create_signature(game_data),
    #     # ThreatLogic.create_signature(game_data)
    #   ]
    #   Abstraction.find_or_create_by(pattern: pattern_signature.join('-'))
    # end
  end
end
