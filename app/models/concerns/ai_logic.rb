module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    possible_moves = find_next_moves

    if find_checkmate(possible_moves).present?
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

  def move_analysis(possible_moves)
    weighted_moves = {}

    current_signature = create_signature(pieces).split('.')
    game_turn = current_turn
    possible_moves.shuffle.each do |possible_move|
      game_setup = possible_move.setup
      total_weight = position_analysis(current_signature, possible_move.value)

      total_weight += [
        game_setup.material_signature,
        game_setup.threat_signature,
        game_setup.attack_signature,
        game_setup.general_attack_signature
      ].reduce(0) { |weight, signature| weight + analyze_signature(signature) }
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

  def position_analysis(signature, possible_move_value)
    best_setups = Move.where(value: possible_move_value).joins(:setup)
    game_setups = best_setups
    previous_moves = moves.order(:move_count).to_a.map(&:value)

    until game_setups.blank? || previous_moves.blank? do
      previous_move = previous_moves.pop
      game_setups = best_setups.where('position_signature LIKE ?', "%#{previous_move}%") if previous_move.present?
      best_setups = game_setups if game_setups.present?
    end

    best_setups.average(:rank).to_f
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
