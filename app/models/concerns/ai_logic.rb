module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    game_notation = wins_from_notation
    return best_move_from_notation(game_notation) if game_notation.present?

    possible_moves = find_next_moves
    best_move = find_checkmate(possible_moves)
    return best_move if best_move.present?

    signatures = possible_moves.map { |move| move.setup.position_signature }
    next_move_setups = Setup.where(position_signature: signatures)

    best_move = setup_analysis(possible_moves, next_move_setups)
    best_move = piece_analysis(possible_moves, next_move_setups) if best_move.blank?

    move(position_index_from_move(best_move.value), best_move.value[-2..-1], promote_pawn(best_move.value))
  end

  def find_next_moves
    pieces.where(color: current_turn).map do |piece|
      all_next_moves_for_piece(piece)
    end.flatten
  end

  def all_next_moves_for_piece(piece)
    piece.valid_moves.map do |move|
      game_move = Move.new(value: piece.position_index.to_s + move, move_count: (moves.count + 1))
      game_pieces = piece.pieces_with_next_move(move)
      game_move.setup = Setup.find_or_create_by(position_signature: create_signature(game_pieces))
      game_move
    end
  end

  def setup_analysis(possible_moves, game_setups)
    best_ranked_position = best_rank_setup(game_setups)

    possible_moves.detect do |move|
      best_ranked_position.present? && move.setup.position_signature == best_ranked_position
    end
  end

  def best_rank_setup(game_setups)
    if current_turn == 'white'
      rank = game_setups.maximum(:rank)
      return nil if rank < 1
    else
      rank = game_setups.minimum(:rank)
      return nil if rank > -1
    end
    game_setups.find_by(rank: rank).position_signature
  end

  def winning_setups
    if current_turn == 'white'
      Setup.where('rank > ?', 0)
    else
      Setup.where('rank < ?', 0)
    end
  end

  def piece_analysis(possible_moves, next_move_setups)
    weighted_moves = {}

    possible_moves.each do |possible_move|
      weight = 0
      current_setup.split('.').each do |position_index|
        weight += handle_ratio(possible_move.value, position_index)
      end
      weighted_moves[weight] = possible_move
    end
    weighted_moves.max_by { |weight, move| weight }.last
  end

  def handle_ratio(index_one, index_two)
    matches = double_position_match(index_one, index_two).count
    total = single_position_match(index_one).count

    if matches == 0 || total == 0
      0
    else
      matches.to_f / total.to_f
    end
  end

  def single_position_match(position_index)
    winning_setups.where('position_signature LIKE ?', "%#{position_index}%")
  end

  def double_position_match(index_one, index_two)
    winning_setups.where('position_signature LIKE ? AND position_signature LIKE ?', "%#{index_one}%", "%#{index_two}%")
  end

  def current_turn
    moves.count.even? ? 'white' : 'black'
  end

  def opponent_turn
    moves.count.even? ? 'black' : 'white'
  end

  def find_checkmate(possible_moves)
    possible_moves.detect do |next_move|
      piece = pieces.find_by(position_index: position_index_from_move(next_move.value))
      game_pieces = piece.pieces_with_next_move(next_move[-2..-1])

      checkmate?(game_pieces, opponent_turn)
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

  def wins_from_notation
    winning_game = random_winning_game
    winning_game.notation.split('.')[moves.count] if winning_game.present?
  end

  def random_winning_game
    win_value = current_turn == 'white' ? 1 : -1

    similar_winning_games = Game.similar_games(notation).winning_games(win_value)
    offset_amount = rand(similar_winning_games.count)
    similar_winning_games.offset(offset_amount).first
  end

  def best_move_from_notation(game_notation)
    update(notation: (notation.to_s + game_notation + '.'))
    update_game_from_notation(game_notation, current_turn)
  end
end
