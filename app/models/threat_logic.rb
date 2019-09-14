class ThreatLogic
  def self.create_signature(game_data)
    threats = game_data.opponents.select { |piece| piece.enemy_targets.present? }

    AttackLogic.find_signature_value(
      threats,
      game_data.target_pieces,
      game_data.pieces
    )
  end
end
