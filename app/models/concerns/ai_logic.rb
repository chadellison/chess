module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    possible_moves = find_next_moves
    signatures = possible_moves.map { |move| move.setup.position_signature }
    next_move_setups = Setup.where(position_signature: signatures)

    best_move = setup_analysis(possible_moves, next_move_setups)
    best_move = piece_analysis(possible_moves, next_move_setups) if best_move.blank?
    # move(position_index, new_position, upgraded_type = '')
    # best_move
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
end
