class CheckmateLogic
  def self.create_signature(setup_data)
    opponent_king =  setup_data.opponents.detect do |piece|
      piece.piece_type == 'king'
    end

    no_moves = setup_data.opponents.none? { |opponent| opponent.valid_moves.present? }

    if setup_data.targets.include?(opponent_king) && no_moves
      setup_data.turn == 'white' ? 10 : -10
    else
      0
    end
  end
end
