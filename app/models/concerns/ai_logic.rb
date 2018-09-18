module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    possible_moves = find_next_moves
    game_notation = wins_from_notation

    if game_notation.present?
      move_from_notation(game_notation)
    elsif find_checkmate(possible_moves).present?
      checkmate_opponent(possible_moves)
    elsif setup_analysis(possible_moves).present?
      best_move = setup_analysis(possible_moves)
      move(position_index_from_move(best_move.value), best_move.value[-2..-1], promote_pawn(best_move.value))
    else
      move_analysis(possible_moves)
    end
  end

  def find_next_moves
    pieces.select { |piece| piece.color == current_turn }.map do |piece|
      all_next_moves_for_piece(piece)
    end.flatten
  end

  def all_next_moves_for_piece(piece)
    piece.valid_moves(pieces).map do |move|
      game_move = Move.new(value: piece.position_index.to_s + move, move_count: (moves.count + 1))
      game_pieces = pieces_with_next_move(pieces, piece.position_index.to_s + move)
      game_move.setup = create_setup(game_pieces)
      game_move
    end
  end

  def move_from_notation(game_notation)
    game_piece = find_piece(game_notation, current_turn)
    move_position = find_move_position(game_notation)
    move_value = game_piece.position_index.to_s + move_position
    move(game_piece.position_index, move_position, promote_pawn(move_value))
  end

  def wins_from_notation
    winning_game = random_winning_game
    winning_game.notation.split('.')[moves.count] if winning_game.present?
  end

  def random_winning_game
    matching_games = Game.similar_games(notation)
    matching_wins = matching_games.winning_games(win_value)

    if matching_wins.count > (matching_games.winning_games(loss_value).count * 0.8)
      offset_amount = rand(matching_wins.count)
      matching_wins.offset(offset_amount).first
    end
  end

  def checkmate_opponent(possible_moves)
    best_move = find_checkmate(possible_moves)
    move(position_index_from_move(best_move.value), best_move.value[-2..-1], promote_pawn(best_move.value))
  end

  # def move_from_analysis(possible_moves)
  #   best_move = setup_analysis(possible_moves)
  #
  #   if best_move.present?
  #     move(position_index_from_move(best_move.value), best_move.value[-2..-1], promote_pawn(best_move.value))
  #   else
  #     move_analysis(possible_moves)
  #   end
  # end

  def setup_analysis(possible_moves)
    signatures = possible_moves.map { |move| move.setup.position_signature }
    game_setups = Setup.where(position_signature: signatures)
    best_ranked_position = best_rank_setup(game_setups)

    possible_moves.detect do |move|
      best_ranked_position.present? && move.setup.position_signature == best_ranked_position
    end
  end

  def best_rank_setup(game_setups)
    if current_turn == 'white'
      rank = game_setups.maximum(:rank)
      return nil if rank.blank? || rank < 1
    else
      rank = game_setups.minimum(:rank)
      return nil if rank.blank? || rank > -1
    end
    game_setups.find_by(rank: rank).position_signature
  end

  def winning_moves
    current_turn == 'white' ? 'rank > ?' : 'rank < ?'
  end

  def move_analysis(possible_moves, weighted_moves = {})
    current_signature = create_signature(pieces).split('.')
    possible_moves.each do |possible_move|
      total_weight = Concurrent::Future.execute do
        position_analysis(current_signature, possible_move.value) +
        material_analysis(possible_move) +
        attack_analysis(possible_move) -
        moves.pluck(:value).select { |move| move == possible_move.value }.count
      end
      weighted_moves[possible_move.value] = total_weight
    end

    retry_move_analysis(possible_moves, weighted_moves)
  end

  def retry_move_analysis(retry_moves, weighted_moves)
    if weighted_moves.any? { |move_value, weight| weight.rejected? }
      retry_move_values = possible_moves.select do |move_value, weight|
        weight.rejected?
      end.map(&:first)

      retry_possible_moves = possible_moves.select do |possible_move|
        retry_move_values.include?(possible_move.value)
      end
      move_analysis(possible_moves, weighted_moves)
    end

    best_move_value = weighted_moves.max_by { |move_value, weight| weight.value }.first

    move(
      position_index_from_move(best_move_value),
      best_move_value[-2..-1],
      promote_pawn(best_move_value)
    )
  end

  def position_analysis(signature, possible_move_value)
    move_values = moves.pluck(:value)
    signature.reduce(0) do |weight, move_value|
      if move_values.include?(move_value)
        weight + handle_ratio(possible_move_value, move_value)
      else
        weight + 0
      end
    end
  end

  def handle_ratio(index_one, index_two)
    matching_moves = find_matching_moves(index_one)

    double_matches = find_double_matching_moves(matching_moves, index_two)

    if double_matches.count == 0 || matching_moves.count == 0
      0
    else
      double_matches.count.to_f / matching_moves.count.to_f
    end
  end

  def find_matching_moves(value)
    Move.where(value: value).joins(:setup).where(winning_moves, 0)
  end

  def find_double_matching_moves(moves, index_two)
    moves.joins(:setup).where(winning_moves, 0)
         .where('position_signature LIKE ?', "%#{index_two}%")
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

  def attack_analysis(game_move)
    if game_move.setup.attack_signature.present?
      rank = game_move.setup.attack_signature.rank
      rank *= -1 if current_turn == 'black'
      rank
    else
      0
    end
  end

  def material_analysis(game_move)
    rank = game_move.setup.material_signature.rank
    rank *= -1 if current_turn == 'black'
    rank
  end

  # def material_analysis(move_value)
  #   next_setup = pieces_with_next_move(pieces, move_value)
  #
  #   current_enemy_setup = pieces.select { |piece| piece.color == opponent_color }
  #   next_enemy_setup = pieces_with_enemy_targets(next_setup, opponent_color)
  #
  #   ally_attack_value(next_setup, current_enemy_setup, next_enemy_setup) +
  #     enemy_attack_value(next_setup, current_enemy_setup)
  # end


  # def ally_attack_value(next_setup, enemy_pieces, next_enemy_setup)
  #   enemy_pieces = pieces.select { |piece| piece.color == opponent_color }
  #   current_enemy_material = enemy_pieces.reduce(0) do |sum, piece|
  #     sum + find_piece_value(piece.piece_type[0].downcase)
  #   end
  #
  #   next_setup_enemy_material = next_enemy_setup.reduce(0) do |sum, piece|
  #     sum + find_piece_value(piece.piece_type[0].downcase)
  #   end
  #
  #   current_enemy_material - next_setup_enemy_material
  # end

  # def enemy_attack_value(next_setup, current_setup)
  #   next_enemy_setup = pieces_with_enemy_targets(next_setup, opponent_color)
  #   find_attacked_value(current_setup) - find_attacked_value(next_enemy_setup)
  # end
  #
  # def pieces_with_enemy_targets(game_pieces, color)
  #   game_pieces.select do |piece|
  #     if piece.color == color
  #       piece.valid_moves(game_pieces)
  #       true
  #     end
  #   end
  # end

  # def find_attacked_value(game_pieces)
  #   enemy_attackers = game_pieces.select { |piece| piece.enemy_targets.present? }
  #
  #   enemy_attackers.reduce(0) do |sum, piece|
  #     attacked_material_value = piece.enemy_targets.reduce(0) do |total, target|
  #       total + find_piece_value(target[0].downcase)
  #     end
  #
  #     sum + attacked_material_value
  #   end
  # end

  # def find_piece_value(piece_type)
  #   { p: 1, n: 3, b: 3, r: 5, q: 9, k: 0 }[piece_type.to_sym]
  # end
end
