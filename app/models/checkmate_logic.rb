class CheckmateLogic
  def self.is_checkmate?(game_data)
    opponent_king = game_data.opponents.detect do |piece|
      piece.piece_type == 'king'
    end

    no_moves = game_data.opponents.none? { |opponent| opponent.valid_moves.present? }

    game_data.targets.include?(opponent_king.position_index) && no_moves
  end
end
