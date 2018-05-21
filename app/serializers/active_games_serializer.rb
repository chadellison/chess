class ActiveGamesSerializer
  class << self
    def serialize(games)
      active_games = games.map do |game|
        {
          id: game.id,
          type: 'game',
          attributes: {
            status: game.status,
            pieces: game.pieces.map { |piece| PieceSerializer.serialize(piece) }
          }
        }
      end

      { data: active_games }
    end
  end
end
