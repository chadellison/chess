class CenterLogic
  def self.create_signature(setup_data)
    center_control_count = setup_data.pieces.reduce(0) do |total, piece|
      count = (piece.valid_moves & ['d4', 'd5', 'e4', 'e5']).count
      if piece.color == 'white'
        total + count
      else
        total - count
      end
    end

    center_pieces = setup_data.pieces.select do |piece|
      ['d4', 'd5', 'e4', 'e5'].include?(piece.position)
    end

    center_defender_count = center_pieces.reduce(0) do |total, piece|
      count = Piece.defenders(piece.position_index, setup_data.pieces).count
      if piece.color == 'white'
        total + count
      else
        total - count
      end
    end

    center_control_count + center_defender_count
  end
end
