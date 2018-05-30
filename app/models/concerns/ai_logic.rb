module AiLogic
  extend ActiveSupport::Concern

  START_INDICES = {
    '1' => 'a8', '2' => 'b8', '3' => 'c8', '4' => 'd8', '5' => 'e8', '6' => 'f8',
    '7' => 'g8', '8' => 'h8', '9' => 'a7', '10' => 'b7', '11' => 'c7',
    '12' => 'd7', '13' => 'e7', '14' => 'f7', '15' => 'g7', '16' => 'h7',
    '17' => 'a2', '18' => 'b2', '19' => 'c2', '20' => 'd2', '21' => 'e2',
    '22' => 'f2', '23' => 'g2', '24' => 'h2', '25' => 'a1', '26' => 'b1',
    '27' => 'c1', '28' => 'd1', '29' => 'e1', '30' => 'f1', '31' => 'g1',
    '32' => 'h1'
  }

  MATERIAL_VALUE = {
    pawn: 1, knight: 3, bishop: 3, rook: 5, queen: 9, king: 0
  }

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
      weight = material_analysis(possible_move.value)
      weight -= moves.pluck(:value).select { |move| move == possible_move.value }.count

      create_signature(pieces).split('.').each do |move_value|
        if possible_move.value[-2..-1] != start_position(possible_move.value)
          weight += handle_ratio(possible_move.value, move_value)
        end
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

  def opponent_color
    moves.count.even? ? 'black' : 'white'
  end

  def find_checkmate(possible_moves)
    possible_moves.detect do |next_move|
      piece = pieces.find_by(position_index: position_index_from_move(next_move.value))
      game_pieces = piece.pieces_with_next_move(next_move[-2..-1])

      # checkmate?(game_pieces, opponent_color)
      false
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
    similar_winning_games = Game.similar_games(notation).winning_games(win_value)
    offset_amount = rand(similar_winning_games.count)
    similar_winning_games.offset(offset_amount).first
  end

  def best_move_from_notation(game_notation)
    update(notation: (notation.to_s + game_notation + '.'))
    update_game_from_notation(game_notation, current_turn)
  end

  def start_position(move_value)
    START_INDICES[position_index_from_move(move_value).to_s]
  end

  def win_value
    current_turn == 'white' ? 1 : -1
  end

  def material_analysis(possible_move_value)
    white_value = find_material_value(pieces, 'white')
    black_value = find_material_value(pieces, 'black')

    material_value = current_turn == 'white' ? white_value - black_value : black_value - white_value

    piece = pieces.find_by(position_index: position_index_from_move(possible_move_value))
    game_pieces = piece.pieces_with_next_move(possible_move_value[-2..-1])

    new_white_value = find_material_value(game_pieces, 'white')
    new_black_value = find_material_value(game_pieces, 'black')

    new_material_value = current_turn == 'white' ? new_white_value - new_black_value : new_black_value - new_white_value
    new_material_value - material_value
  end

  def find_material_value(game_pieces, color)
    game_pieces.select { |piece| piece.color == color }.reduce(0) do |sum, piece|
      sum + MATERIAL_VALUE[piece.piece_type.to_sym]
    end
  end
end
