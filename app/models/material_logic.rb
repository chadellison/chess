class MaterialLogic
  def self.create_signature(game_data)
    pieces = game_data[:pieces]
    targets = pieces.map(&:enemy_targets).flatten

    pieces.reduce(0) do |total, piece|
      if game_data[:turn] == piece.color || !targets.include?(piece.position_index)
        piece_value = piece.find_piece_value
        if piece.color == 'white'
          total + piece_value
        else
          total - piece_value
        end
      else
        total
      end
    end
  end
end
