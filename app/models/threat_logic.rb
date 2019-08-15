class ThreatLogic
  def self.create_signature(game_data, pieces_to_evaluate)
    threats = game_data.find_threats(pieces_to_evaluate)
    next_targets = pieces_to_evaluate.select do |piece|
      piece.color == game_data.turn && game_data.targets.include?(piece.position_index)
    end

    AttackLogic.find_signature_value(threats, next_targets, game_data.pieces)
  end
end
