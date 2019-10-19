class GameData
  attr_reader :move, :pieces, :turn, :targets

  def initialize(move, pieces, turn)
    @move = move
    @pieces = pieces
    @turn = turn
    @targets = pieces.map(&:enemy_targets).flatten
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
end
