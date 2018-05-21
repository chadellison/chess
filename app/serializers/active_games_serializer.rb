class ActiveGamesSerializer
  def self.serialize(games)
    active_games = games.map do |game|
      {
        id: game.id,
        type: 'game',
        attributes: {
          pieces: game.pieces.map { |piece| PieceSerializer.serialize(piece) }
        }
      }
    end

    { data: active_games }
  end
end
