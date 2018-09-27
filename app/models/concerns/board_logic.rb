module BoardLogic
  extend ActiveSupport::Concern

  def pieces_with_next_move(game_pieces, move)
    game_pieces.reject { |piece| piece.position == move[-2..-1] }
      .map do |piece|
        game_piece = Piece.new(
          color: piece.color,
          piece_type: piece.piece_type,
          position_index: piece.position_index,
          game_id: piece.game_id,
          position: piece.position,
          moved_two: piece.moved_two,
          has_moved: piece.has_moved
        )

        if piece.position_index == position_index_from_move(move)
          game_piece.position = move[-2..-1]
          game_piece.has_moved = true
        end

        game_piece
      end
  end

  def update_notation(position_index, new_position, upgraded_type)
    new_notation = create_notation(position_index, new_position, upgraded_type)

    update(notation: (notation.to_s + new_notation.to_s))
  end

  def update_game(piece, new_position, upgraded_type = '')
    updated_piece = update_piece(piece, new_position, upgraded_type)
    update_board(piece, updated_piece)
  end

  def update_piece(piece, new_position, upgraded_type)
    Piece.new(
      position_index: piece.position_index,
      position: new_position,
      has_moved: true,
      piece_type: (upgraded_type.present? ? upgraded_type : piece.piece_type)
    )
  end

  def update_board(piece, updated_piece)
    new_pieces = pieces_with_next_move(pieces, updated_piece.position_index.to_s + updated_piece.position)
    new_pieces = handle_castle(piece, updated_piece.position, new_pieces) if piece.king_moved_two?(updated_piece.position)
    new_pieces = handle_en_passant(piece, updated_piece.position, new_pieces) if en_passant?(piece, updated_piece.position)
    update_pieces(new_pieces)
    game_move = new_move(updated_piece)
    game_move.setup = create_setup(new_pieces)
    game_move.save
  end

  def create_setup(new_pieces)
    setup = Setup.find_or_create_by(position_signature: create_signature(new_pieces))
    new_pieces.each { |piece| piece.valid_moves(new_pieces) }
    game_turn_code = current_turn[0]
    setup.attack_signature = handle_attack_signature(new_pieces, game_turn_code)
    setup.threat_signature = handle_threat_signature(new_pieces, game_turn_code)
    setup.material_signature = MaterialSignature.find_or_create_by(
      signature: (new_pieces.map(&:position_index).join + game_turn_code)
    )
    setup.save
    setup
  end

  def handle_attack_signature(new_pieces, game_turn_code)
    attack_signature = create_attack_signature(new_pieces, game_turn_code)
    if attack_signature.present?
      AttackSignature.find_or_create_by(signature: attack_signature)
    end
  end

  def handle_threat_signature(new_pieces, game_turn_code)
    threat_signature = create_threat_signature(new_pieces, game_turn_code)
    if threat_signature.length > 1
      ThreatSignature.find_or_create_by(signature: threat_signature)
    end
  end

  def create_attack_signature(new_pieces, game_turn_code)
    signature = new_pieces.select { |piece| piece.enemy_targets.present? }.map do |piece|
      piece.find_piece_code + 'x' + piece.enemy_targets.join('x')
    end
    if signature.present?
      signature.push(game_turn_code)
      signature.join('.')
    end
  end

  def create_threat_signature(new_pieces, game_turn_code)
    white_king_spaces = new_pieces.detect { |piece| piece.position_index == 29 }.spaces_near_king
    black_king_spaces = new_pieces.detect { |piece| piece.position_index == 5 }.spaces_near_king

    black_pieces = new_pieces.select { |piece| piece.color == 'black' }
    white_pieces = new_pieces.select { |piece| piece.color == 'white' }

    white_threats = map_enemy_threats(white_king_spaces, black_pieces, new_pieces)
    black_threats = map_enemy_threats(black_king_spaces, white_pieces, new_pieces)
    white_threats + black_threats + game_turn_code
  end

  def map_enemy_threats(spaces, enemy_pieces, new_pieces)
    enemy_pieces.select do |enemy_piece|
      (enemy_piece.valid_moves(new_pieces) & spaces).present?
    end.map do |enemy_piece|
      enemy_piece.find_piece_code + spaces.select { |space| enemy_piece.valid_moves(new_pieces).include?(space) }.join
    end.join('.')
  end

  def new_move(piece)
    promoted_pawn = promoted_pawn?(piece) ? piece.piece_type : nil
    moves.new(
      value: (piece.position_index.to_s + piece.position),
      move_count: (moves.count + 1),
      promoted_pawn: promoted_pawn
    )
  end

  def promoted_pawn?(piece)
    (9..24).include?(piece.position_index) && piece.piece_type != 'pawn'
  end

  def create_signature(game_pieces)
    game_pieces.sort_by(&:position_index).map do |piece|
      piece.position_index.to_s + piece.position
    end.join('.')
  end

  def handle_castle(piece, new_position, updated_pieces)
    column_difference = piece.position[0].ord - new_position[0].ord
    row = piece.color == 'white' ? '1' : '8'

    new_pieces = updated_pieces

    if column_difference == -2
      new_pieces = new_pieces.map do |game_piece|
        game_piece.position = ('f' + row) if game_piece.position == ('h' + row)
        game_piece
      end
    end

    if column_difference == 2
      new_pieces = new_pieces.map do |game_piece|
        game_piece.position = ('d' + row) if game_piece.position == ('a' + row)
        game_piece
      end
    end

    new_pieces
  end

  def handle_en_passant(piece, new_position, updated_pieces)
    captured_position = new_position[0] + piece.position[1]
    updated_pieces.reject { |game_piece| game_piece.position == captured_position}
  end

  def en_passant?(piece, position)
    [
      piece.piece_type == 'pawn',
      piece.position[0] != position[0],
      pieces.detect { |piece| piece.position == position }.blank?
    ].all?
  end

  def checkmate?(game_pieces, turn)
    no_valid_moves?(game_pieces, turn) &&
      !pieces.detect { |piece| piece.color == turn }.king_is_safe?(turn, game_pieces)
  end

  def stalemate?(game_pieces, turn)
    king = pieces.detect { |piece| piece.color == current_turn }
    [
      no_valid_moves?(game_pieces, turn) && king.king_is_safe?(current_turn, game_pieces),
      insufficient_pieces?,
      three_fold_repitition?
    ].any?
  end

  def insufficient_pieces?
    black_pieces = pieces.select { |piece| piece.color == 'black' }.map(&:piece_type)
    white_pieces = pieces.select { |piece| piece.color == 'white' }.map(&:piece_type)
    piece_types = ['queen', 'pawn', 'rook']

    [black_pieces, white_pieces].all? do |pieces_left|
      pieces_left.count < 3 &&
        pieces_left.none? { |piece| piece_types.include?(piece) }
    end
  end

  def three_fold_repitition?
    moves.count > 9 && moves.last(8).map(&:value).uniq.count < 5
  end

  def no_valid_moves?(game_pieces, turn)
    game_pieces.select { |piece| piece.color == turn }.all? do |piece|
      piece.valid_moves(game_pieces).blank?
    end
  end
end
