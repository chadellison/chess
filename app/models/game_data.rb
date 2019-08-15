class GameData
  attr_reader :move, :pieces, :turn, :material_value, :targets

  def initialize(move, pieces, turn, material_value)
    @move = move
    @pieces = pieces
    @material_value = material_value
    @turn = turn
    @targets = pieces.map(&:enemy_targets).flatten
  end

  def opponents
    pieces.select { |piece| piece.color != turn }
  end

  def allies
    pieces.select { |piece| piece.color == turn }
  end

  def enemy_territory?(piece)
    [
      (piece.color == 'white' && piece.position[1].to_i > 4),
      (piece.color == 'black' && piece.position[1].to_i < 5)
    ].any?
  end

  def next_attackers(pieces_to_evaluate)
    pieces_to_evaluate.select do |piece|
      [
        piece.enemy_targets.present?,
        piece.color == turn
      ].all?
    end
  end

  def find_threats(pieces_to_evaluate)
    pieces_to_evaluate.select do |piece|
      [
        piece.enemy_targets.present?,
        piece.color != turn
      ].all?
    end
  end

  def target_pieces
    @target_pieces ||= pieces.select { |piece| targets.include?(piece.position_index) }
  end

  def pawns
    @pawns ||= pieces_by_type('pawn')
  end

  def knights
    @knights ||= pieces_by_type('knight')
  end

  def bishops
    @bishops ||= pieces_by_type('bishop')
  end

  def rooks
    @rooks ||= pieces_by_type('rook')
  end

  def queens
    @queens ||= pieces_by_type('queen')
  end

  def kings
    @kings ||= pieces_by_type('king')
  end

  def pieces_by_type(piece_type)
    pieces.select { |piece| piece.piece_type == piece_type }
  end
end
