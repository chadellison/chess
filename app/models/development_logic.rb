class DevelopmentLogic
  def self.development_pattern(game_data)
    ally_development = 0
    total_development = 0
    game_data.pieces.each do |piece|
      if piece.has_moved
        ally_development += 1 if piece.color == game_data.turn
        total_development += 1
      end
    end

    if game_data.turn == 'white'
      ally_development -= 1
      total_development -= 1
    end

    return 0.0 if total_development == 0
    (ally_development.to_f / total_development.to_f).round(1)
  end
end
