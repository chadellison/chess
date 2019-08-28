class GameData
  attr_reader :move, :pieces, :turn, :material_value, :targets

  def initialize(move, pieces, turn, material_value)
    @move = move
    @pieces = pieces
    @material_value = material_value
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
end
