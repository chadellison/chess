class GameSerializer
  class << self
    def serialize(game)
      {
        id: game.id,
        type: 'game',
        attributes: {
          status: game.status,
          currentTurn: game.current_turn,
          outcome: game.outcome,
          whitePlayer: game.white_player,
          blackPlayer: game.black_player,
        },
        pieces: game.pieces.map { |piece| PieceSerializer.serialize(piece) }
      }
    end
  end
end
