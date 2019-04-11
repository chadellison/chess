class GameSerializer
  class << self
    def serialize(game)
      {
        id: game.id,
        type: 'game',
        attributes: {
          status: game.status,
          currentTurn: game.current_turn,
          outcome: format_outcome(game.outcome),
          whitePlayer: PlayerSerializer.serialize(game.white_player),
          blackPlayer: PlayerSerializer.serialize(game.black_player),
          aiPlayer: AiPlayerSerializer.serialize(game.ai_player),
          gameType: game.game_type,
          notation: game.notation,
          moves: game.moves.order(:move_count).pluck(:value)
        },
        pieces: game.pieces.map { |piece| PieceSerializer.serialize(piece) }
      }
    end

    def format_outcome(outcome)
      case outcome
      when '1' then 'White wins!'
      when '0' then 'Black wins!'
      when '0.5' then 'Draw'
      end
    end
  end
end
