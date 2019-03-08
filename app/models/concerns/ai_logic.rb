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
    setup_key = last_move.present? ? last_move.setup_id : 'initial_setup'
    if in_cache?(setup_key)
      get_next_moves_from_cache(setup_key)
    else
      next_moves = pieces.select { |piece| piece.color == game_turn }.map do |piece|
        all_next_moves_for_piece(piece)
      end.flatten
      add_to_cache(setup_key, next_moves)
      next_moves
    end
  end

  def all_next_moves_for_piece(piece)
    piece.valid_moves(pieces).map do |move|
      move_value = piece.position_index.to_s + move

      game_move = Move.new(value: move_value, move_count: (moves.count + 1))
      game_pieces = pieces_with_next_move(pieces, move_value)

      game_move.setup = create_setup(game_pieces)
      game_move.material_value = MaterialLogic.calculate_value(game_pieces, opponent_color[0])
      game_move
    end
  end

  def checkmate_opponent(possible_moves)
    best_move = find_checkmate(possible_moves)
    handle_move(best_move.value, promote_pawn(best_move.value))
  end

  def matching_setup?(possible_moves, game_turn)
    possible_moves.any? do |possible_move|
      if possible_move.setup.outcomes.present?
        average_win_amount = possible_move.setup.average_outcome
        if game_turn == 'black'
          average_win_amount < 0.2
        else
          average_win_amount > -0.2
        end
      end
    end
  end

  def move_from_setup(possible_moves, game_turn)
    best_move = possible_moves.max_by do |possible_move|
      if game_turn == 'black'
        possible_move.setup.rank * -1
      else
        possible_move.setup.rank
      end
    end

    handle_move(best_move.value, promote_pawn(best_move.value))
  end

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    possible_moves.shuffle.each do |possible_move|
      setup = possible_move.setup
      binding.pry if possible_move.material_value.blank?
      total_weight = setup.signatures.reduce(possible_move.material_value) do |weight, signature|
        log_move_data(game_turn, signature, possible_move)
        weight + signature.rank
      end

      total_weight *= -1 if game_turn == 'black'
      weighted_moves[possible_move.value] = total_weight
    end
    find_best_move(weighted_moves)
  end

  def log_move_data(game_turn, signature, possible_move)
    puts "^^^^^^^^^^^^^^^^^^^^^^#{game_turn}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    puts "$$$$$$$$$$$$$$$$ TYPE #{signature.signature_type}$$$$$$$$$$$$$$$$$$$$$$$"
    puts "$$$$$$$$$$$$$$$$ SIGNATURE: #{signature.value}$$$$$$$$$$$$$$$$$$$$$$$"
    puts "******************* MATERIAL VALUE: #{possible_move.material_value}*****************"
    puts "******************* MOVE VALUE: #{possible_move.value} #{signature.rank.to_s}*****************"
  end

  def find_best_move(weighted_moves)
    best_move_value = weighted_moves.max_by { |move_value, weight| weight }.first

    handle_move(best_move_value, promote_pawn(best_move_value))
  end

  def find_checkmate(possible_moves)
    possible_moves.detect do |next_move|
      game_pieces = pieces_with_next_move(pieces, next_move.value)
      checkmate?(game_pieces, opponent_color)
    end
  end

  def crossed_pawn?(move_value)
    (9..24).include?(move_value.to_i) &&
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
