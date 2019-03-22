class Analytics
  attr_reader :setup

  def initialize(setup)
    @setup = setup
  end

  def win_ratio
    setup_outcomes = {}
    setup_outcomes = setup.outcomes if setup.present?
    attributes = {
      whiteWins: setup_outcomes[:white_wins].to_i,
      blackWins: setup_outcomes[:black_wins].to_i,
      draws: setup_outcomes[:draws].to_i
    }
    AnalyticsSerializer.serialize(attributes)
  end

  def next_move_analytics(moves)
    game = Game.new
    game.moves = moves.map { |attributes| Move.new(attributes) }

    if game.moves.blank?
      game.pieces
    else
      game.last_move.setup = setup
    end

    turn = game.moves.size.even? ? 'white' : 'black'
    ai = AiLogic.new(game)
    attributes = ai.find_next_moves(turn).map do |move|
      signatures = move.setup.signatures
      setup_weight = move.setup.average_outcome
      material_weight = find_weight(signatures, 'material')
      attack_weight = find_weight(signatures, 'attack')
      threat_weight = find_weight(signatures, 'threat')
      activity_weight = find_weight(signatures, 'activity')
      {
        move: move.value,
        setupWeight: setup_weight,
        materialWeight: material_weight,
        attackWeight: attack_weight,
        threatWeight: threat_weight,
        activityWeight: activity_weight,
        totalWeight: ((setup_weight + material_weight + attack_weight + threat_weight + activity) / 5)
      }
    end
    AnalyticsSerializer.serialize(attributes)
  end

  def find_weight(signatures, signature_type)
    signature = signatures.detect do |signature|
      signature.signature_type == signature_type
    end
    return 0 if signature.blank?
    signature.average_outcome
  end
end
