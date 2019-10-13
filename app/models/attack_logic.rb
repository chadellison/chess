class AttackLogic
  def self.find_pattern(game_data)
    defenders = []
    game_data.targets.each do |target|
      defenders += Piece.defenders(target, game_data.pieces).map(&:position_index)
    end

    attackers_and_targets = defenders + game_data.targets
    involved_in_attack = game_data.pieces.select do |piece|
      attackers_and_targets.include?(piece.position_index) ||
        piece.enemy_targets.present?
    end.uniq
    Signature.create_signature(involved_in_attack, game_data.turn[0])
  end
end
