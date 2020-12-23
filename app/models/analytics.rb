class Analytics
  def self.analyze_position(notation)
    fen_notation = PGN::Game.new(notation.split(' ')).positions.last.to_fen.to_s
    analyzed_moves = CacheService.hget('analytics', fen_notation)
    if  analyzed_moves.present?
      analyzed_moves
    else
      analyzed_moves = AiLogic.new.analyze_position(fen_notation)
      CacheService.hset('analytics', fen_notation, analyzed_moves)
    end
    AnalyticsSerializer.serialize(analyzed_moves)
  end
end
