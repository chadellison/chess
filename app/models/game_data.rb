class GameData
  attr_reader :pieces, :turn, :targets

  def initialize(pieces, turn)
    @pieces = pieces
    @turn = turn
    @targets = pieces.map(&:enemy_targets).uniq.flatten
  end

  def opponents
    @opponents ||= pieces.select { |piece| piece.color != turn }
  end
end
