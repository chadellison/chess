module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    # possible_moves =
    # next_move_setups = Setup.where(position_signature: find_next_move_signatures)
    # find_best_move(next_move_setups)
  end

  def find_best_move(next_move_setups)
    if current_turn == 'white'
      # best_setup = next_move_setups.maximum(:rank)
    else
      # best_setup = next_move_setups.minimum(:rank)
    end
  end

  def find_next_move_signatures
    pieces.where(color: current_turn).map do |piece|
      piece.valid_moves.map do |move|
        Move.new(value: piece.position_index.to_s + move)
        piece.pieces_with_next_move(move) end
           # .map { |game_pieces| create_signature(game_pieces) }
    end.flatten
  end

  def current_turn
    notation.to_s.split('.').count.even? ? 'white' : 'black'
  end
end
