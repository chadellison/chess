module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    # max by / min by setup rank (based on color)
    setups = Setup.where(position_signature: find_next_move_signatures)

    # find best game
    # if current_turn == 'white'
      # setups.maximum(:rank)
      # else
      # setups.minimum(:rank)
      #
      # if no best game exists
      # move analysis
  end

  def find_next_move_signatures
    pieces.where(color: current_turn).map do |piece|
      piece.valid_moves.map { |move| piece.pieces_with_next_move(move) }
           .map { |game_pieces| create_signature(game_pieces) }
    end.flatten
  end

  def current_turn
    notation.to_s.split('.').count.even? ? 'white' : 'black'
  end
end
