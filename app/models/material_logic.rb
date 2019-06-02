class MaterialLogic
  def self.create_signature(new_pieces)
    all_targets = new_pieces.map { |piece| piece.enemy_targets }.flatten

    new_pieces.reduce(0) do |total, piece|
      unless all_targets.include?(piece.position_index)
        piece_value = piece.find_piece_value
        if piece.color == 'white'
          total + piece_value
        else
          total - piece_value
        end
      end
    end
  end
end
