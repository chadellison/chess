class GameData
  attr_reader :pieces, :turn, :targets

  def initialize(pieces, turn_code)
    @pieces = pieces
    @turn = turn_code == 'w' ? 'white' : 'black'
    @targets = pieces.map(&:enemy_targets).flatten
  end

  def calculate_piece_quality(pieces)
    pieces.reduce(0) do |total, piece|
      value_to_increment = 0
      unless turn == piece.color && targets.include?(piece.position_index)
        value_to_increment += 1 if piece.has_moved
        value_to_increment += 1 if enemy_territory?(piece)
        value_to_increment += piece.valid_moves.count
        value_to_increment += piece.enemy_targets.count
        value_to_increment *= -1 if piece.color == 'black'
      end
      total + value_to_increment
    end
  end

  def enemy_territory?(piece)
    [
      (piece.color == 'white' && piece.position[1].to_i > 4),
      (piece.color == 'black' && piece.position[1].to_i < 5)
    ].any?
  end
end
