module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    game_turn = current_turn
    possible_moves = find_next_moves(game_turn)

    if find_checkmate(possible_moves).present?
      checkmate_opponent(possible_moves)
    elsif matching_setup?(possible_moves, game_turn)
      move_from_setup(possible_moves, game_turn)
    else
      move_analysis(possible_moves, game_turn)
    end
  end

  def find_next_moves(game_turn)
    pieces.select { |piece| piece.color == game_turn }.map do |piece|
      all_next_moves_for_piece(piece)
    end.flatten
  end

  def all_next_moves_for_piece(piece)
    piece.valid_moves(pieces).map do |move|
      move_value = piece.position_index.to_s + move

      game_move = Move.new(value: move_value, move_count: (moves.count + 1))
      game_pieces = pieces_with_next_move(pieces, move_value)
      game_move.setup = create_setup(game_pieces)
      game_move
    end
  end

  def checkmate_opponent(possible_moves)
    best_move = find_checkmate(possible_moves)
    handle_move(position_index_from_move(best_move.value), best_move.value[-2..-1], promote_pawn(best_move.value))
  end

  def matching_setup?(possible_moves, game_turn)
    if game_turn == 'black'
      possible_moves.any? { |possible_move| possible_move.setup.rank < 0 }
    else
      possible_moves.any? { |possible_move| possible_move.setup.rank > 0 }
    end
  end

  def move_from_setup(possible_moves, game_turn)
    best_move = possible_moves.max_by do |possible_move|
      if game_turn == 'black'
        possible_move.rank * -1
      else
        possible_move.rank
      end
    end

    handle_move(position_index_from_move(best_move), best_move[-2..-1], promote_pawn(best_move))
  end

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}
    previous_moves = moves.map { |move| position_index_from_move(move.value) }

    possible_moves.shuffle.each do |possible_move|
      setup = possible_move.setup

      total_weight = setup.signatures.reduce(0) do |weight, signature|
        puts "$$$$$$$$$$$$$$$$#{signature.signature_type}$$$$$$$$$$$$$$$$$$$$$$$"
        puts "$$$$$$$$$$$$$$$$#{signature.value}$$$$$$$$$$$$$$$$$$$$$$$"
        puts "******************* #{possible_move.value} #{signature.rank.to_s}*****************"
        weight + signature.rank
      end
      total_weight *= -1 if game_turn == 'black'
      weighted_moves[possible_move.value] = total_weight
    end
    find_best_move(weighted_moves)
  end

  def find_best_move(weighted_moves)
    best_move = weighted_moves.max_by do |move_value, weight|
      weight
    end.first

    handle_move(position_index_from_move(best_move), best_move[-2..-1], promote_pawn(best_move))
  end

  def find_checkmate(possible_moves)
    possible_moves.detect do |next_move|
      game_pieces = pieces_with_next_move(pieces, next_move.value)
      checkmate?(game_pieces, opponent_color)
    end
  end

  def position_index_from_move(move_value)
    move_value.length == 3 ? move_value[0].to_i : move_value[0..1].to_i
  end

  def crossed_pawn?(move_value)
    (9..24).include?(position_index_from_move(move_value)) &&
      (move_value[-1] == '1' || move_value[-1] == '8')
  end

  def promote_pawn(move_value)
    crossed_pawn?(move_value) ? 'queen' : ''
  end

  def win_value
    current_turn == 'white' ? 1 : -1
  end

  def loss_value
    win_value == 1 ? -1 : 1
  end
end
