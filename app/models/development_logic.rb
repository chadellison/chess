class DevelopmentLogic
  def self.create_signature(game_data)
    ally_development = 0
    total_development = 0
    game_data.pieces.each do |piece|
      if piece.has_moved
        ally_development += 1 if piece.color == game_data.turn
        total_development += 1
      end
    end

    (ally_development.to_f / total_development.to_f).round(1)
  end
end
