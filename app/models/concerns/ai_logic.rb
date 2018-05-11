module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    # possible_moves = find_next_moves
    # signatures = possible_moves.map { |move| move.setup.position_signature }
    # next_move_setups = Setup.where(position_signature: signatures)
    #
    # best_setup = find_best_move(possible_moves)
    # best_move = possible_moves.detect { |move| move.setup.position_index == best_setup }

    # move(position_index, new_position, upgraded_type = '')
  end

  def find_best_move(next_move_setups)
    if current_turn == 'white'
      # best_setup = next_move_setups.maximum(:rank)
    else
      # best_setup = next_move_setups.minimum(:rank)
    end
  end

  def find_next_moves
    pieces.where(color: current_turn).map do |piece|
      piece.valid_moves.map do |move|
        game_move = Move.new(value: piece.position_index.to_s + move, move_count: (moves.count + 1))
        game_pieces = piece.pieces_with_next_move(move)
        game_move.setup = Setup.create(position_signature: create_signature(game_pieces))
        game_move
      end
    end.flatten
  end

  def current_turn
    notation.to_s.split('.').count.even? ? 'white' : 'black'
  end
end
