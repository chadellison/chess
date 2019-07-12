class XRayLogic
  TARGET_VALUE = {
    1 => 5, 2 => 3, 3 => 3, 4 => 9, 5 => 10, 6 => 3, 7 => 3, 8 => 5, 9 => 1,
    10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1, 17 => 1,
    18 => 1, 19 => 1, 20 => 1, 21 => 1, 22 => 1, 23 => 1, 24 => 1, 25 => 5,
    26 => 3, 27 => 3, 28 => 9, 29 => 10, 30 => 3, 31 => 3, 32 => 5
  }

  def self.create_signature(game_data)
    pieces = game_data[:pieces]
    white_pieces = pieces.select { |piece| piece.color == 'white' }
    black_pieces = pieces.select { |piece| piece.color == 'black' }

    pieces.reduce(0) do |total, piece|
      x_ray_moves = piece.moves_for_piece
      if piece.color == 'white'
        total + find_sum(x_ray_moves, black_pieces)
      else
        total - find_sum(x_ray_moves, white_pieces)
      end
    end
  end

  def self.find_sum(x_ray_moves, pieces)
    pieces.select { |piece| x_ray_moves.include?(piece.position) }
          .reduce(0) { |sum, piece| sum + TARGET_VALUE[piece.position_index] }
  end
end
