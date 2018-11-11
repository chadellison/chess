module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    game_turn = current_turn
    possible_moves = find_next_moves(game_turn)

    if find_checkmate(possible_moves).present?
      checkmate_opponent(possible_moves)
    else
      move_analysis(possible_moves, game_turn)
    end
  end

  def find_next_moves(game_turn)
    pieces.select { |piece| piece.color == game_turn }.map do |piece|
      all_next_moves_for_piece(piece, game_turn)
    end.flatten
  end

  def all_next_moves_for_piece(piece, game_turn)
    piece.valid_moves(pieces).map do |move|
      move_value = piece.position_index.to_s + move

      game_move = Move.new(value: move_value, move_count: (moves.count + 1))
      game_pieces = pieces_with_next_move(pieces, move_value)
      game_move.setup = create_setup(game_pieces, game_turn)
      game_move
    end
  end

  def checkmate_opponent(possible_moves)
    best_move = find_checkmate(possible_moves)
    move(position_index_from_move(best_move.value), best_move.value[-2..-1], promote_pawn(best_move.value))
  end

  def move_analysis(possible_moves, game_turn)
    weighted_moves = {}

    previous_moves = moves.map { |move| position_index_from_move(move.value) }

    possible_moves.shuffle.each do |possible_move|
      game_setup = possible_move.setup
      total_weight = position_analysis(possible_move, previous_moves)

      total_weight += game_setup.all_signatures.reduce(0) do |weight, signature|
        weight + analyze_signature(signature)
      end
      total_weight *= -1 if game_turn == 'black'
      weighted_moves[possible_move.value] = total_weight
    end
    find_best_move(weighted_moves)
  end

  def find_best_move(weighted_moves)
    best_move_value = weighted_moves.max_by do |move_value, weight|
      puts move_value + ' ********* WEIGHT ********* ' + weight.to_s
      weight
    end.first

    move(
      position_index_from_move(best_move_value),
      best_move_value[-2..-1],
      promote_pawn(best_move_value)
    )
  end

  def position_analysis(possible_move, previous_moves)
    similar_setups = Move.where(value: possible_move.value).joins(:setup)
    game_setups = similar_setups

    possible_move.setup.position_signature.split('.').each do |move_value|
      if previous_moves.include?(position_index_from_move(move_value))
        game_setups = similar_setups.where('position_signature LIKE ?', "%#{move_value}%")
        similar_setups = game_setups if game_setups.present?
      end
    end

    similar_setups.average(:rank).to_f
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

  def analyze_signature(signature)
    signature.present? ? signature.rank : 0
  end
end
