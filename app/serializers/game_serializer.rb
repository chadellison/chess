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
          whitePlayer: PlayerSerializer.serialize(game.white_player, game.game_type),
          blackPlayer: PlayerSerializer.serialize(game.black_player, game.game_type),
          gameType: game.game_type
        },
        pieces: game.pieces.map { |piece| PieceSerializer.serialize(piece) }
      }
    end
  end
end
