class GameData
  attr_reader :move, :pieces, :turn, :material_value, :targets

  def initialize(move, pieces, turn, material_value)
    @move = move
    @pieces = pieces
    @material_value = material_value
    @turn = turn
    @targets = pieces.map(&:enemy_targets).flatten
  end

  def defender_index
    if @defender_index.present?
      @defender_index
    else
      @defender_index = {}
      pieces.each do |piece|
        key = piece.position_index
        @defender_index[key] = Piece.defenders(key, pieces)
      end
      @defender_index
    end
  end

  def opponent_color
    turn == 'white' ? 'black' : 'white'
  end

  def opponents
    @opponents ||= pieces.select { |piece| piece.color != turn }
  end

  def allies
    @allies ||= pieces.select { |piece| piece.color == turn }
  end

  def target_pieces
    @target_pieces ||= pieces.select { |piece| targets.include?(piece.position_index) }
  end

  def ally_attackers
    allies.select { |ally| ally.enemy_targets.present? }
  end

  def ally_targets
    target_pieces.select { |target_piece| target_piece == turn }
  end

  def opponent_targets
    target_pieces.select { |target_piece| target_piece == opponent_color }
  end

  def pawns
    @pawns ||= pieces.select { |piece| piece.piece_type == 'pawn' }
  end
end
