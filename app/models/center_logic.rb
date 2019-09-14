class CenterLogic
  CENTER_SQUARES = [
    'c6', 'd6', 'e6', 'f6', 'c5', 'd5', 'e5', 'f5', 'c4', 'd4', 'e4', 'f4',
    'c3', 'd3', 'e3', 'f3'
  ]

  def self.center_control_pattern(game_data)
    control_count = 0
    total_center_coverage = 0
    CENTER_SQUARES.each do |square|
      game_data.pieces.each do |piece|
        if piece.valid_moves.include?(square) || piece.position == square
          if piece.color == game_data.turn
            control_count += 1
          end
          total_center_coverage += 1
        end
      end
    end
    (control_count.to_f / total_center_coverage.to_f).round(1)
  end
end
