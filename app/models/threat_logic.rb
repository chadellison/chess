class ThreatLogic
  def self.find_pattern(game_data)
    attackers = []
    game_data.pieces.each do |piece|
      if piece.enemy_targets.present?
        attackers << piece.find_piece_code + piece.enemy_targets.join('.')
      end
    end

    attackers.join(':') + game_data.turn[0]
  end
end
