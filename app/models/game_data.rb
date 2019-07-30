class GameData
  attr_reader :pieces, :turn, :targets

  def initialize(pieces, turn_code)
    @pieces = pieces
    @turn = turn_code == 'w' ? 'white' : 'black'
    @targets = pieces.map(&:enemy_targets).flatten
  end
end
