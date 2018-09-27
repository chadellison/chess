module AiLogic
  extend ActiveSupport::Concern

  OPENINGS = ['19c4', '20d4', '21ef', '31f3']

  def ai_move
    possible_moves = find_next_moves

    if moves.blank?
      opening = OPENINGS.sample
      move(position_index_from_move(opening), opening[-2..-1], '')
    elsif find_checkmate(possible_moves).present?
      checkmate_opponent(possible_moves)
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

  def checkmate_opponent(possible_moves)
    best_move = find_checkmate(possible_moves)
    move(position_index_from_move(best_move.value), best_move.value[-2..-1], promote_pawn(best_move.value))
  end

  def move_analysis(possible_moves, weighted_moves = {})
    current_signature = create_signature(pieces).split('.')
    game_turn = current_turn
    possible_moves.shuffle.each do |possible_move|
      total_weight = Concurrent::Future.execute do
        position_analysis(current_signature, possible_move.value, game_turn) +
        material_analysis(possible_move.setup.material_signature, game_turn) +
        threat_analysis(possible_move.setup.threat_signature, game_turn) +
        attack_analysis(possible_move.setup.attack_signature, game_turn) -
        moves.pluck(:value).select { |move| move == possible_move.value }.count
      end
      weighted_moves[possible_move.value] = total_weight
    end

    retry_move_analysis(possible_moves, weighted_moves)
  end

  def retry_move_analysis(retry_moves, weighted_moves)
    if weighted_moves.any? { |move_value, weight| weight.rejected? }
      'RETRY MOVES'
      retry_move_values = possible_moves.select do |move_value, weight|
        weight.rejected?
      end.map(&:first)

      retry_possible_moves = possible_moves.select do |possible_move|
        retry_move_values.include?(possible_move.value)
      end
      move_analysis(possible_moves, weighted_moves)
    end

    best_move_value = weighted_moves.max_by do |move_value, weight|
      puts move_value + ' ********* WEIGHT ********* ' + weight.value.to_s
      weight.value
    end.first

    move(
      position_index_from_move(best_move_value),
      best_move_value[-2..-1],
      promote_pawn(best_move_value)
    )
  end

  def position_analysis(signature, possible_move_value, game_turn)
    move_values = moves.pluck(:value)
    signature.reduce(0) do |weight, move_value|
      if move_values.include?(move_value)
        setup_weight = Move.where(value: possible_move_value).joins(:setup).where('position_signature LIKE ?',
                                  "%#{move_value}%").average(:rank).to_f.round(4)
        setup_weight *= -1 if game_turn == 'black'
        weight + setup_weight
      else
        weight + 0
      end
    end
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

  def attack_analysis(attack_signature, game_turn)
    if attack_signature.present?
      rank = attack_signature.rank
      rank *= -1 if game_turn == 'black'
      rank
    else
      0
    end
  end

  def material_analysis(material_signature, game_turn)
    rank = material_signature.rank
    rank *= -1 if game_turn == 'black'
    rank
  end

  def threat_analysis(threat_signature, game_turn)
    if threat_signature.present?
      rank = threat_signature.rank
      rank *= -1 if game_turn == 'black'
      rank
    else
      0
    end
  end
end
