class ActivityLogic
  def self.create_signature(setup_data)
    return 0 if setup_data.targets.any? { |target| [5, 29].include?(target) }

    setup_data.pieces.reduce(0) do |total, piece|
      if setup_data.turn == piece.color && setup_data.targets.include?(piece.position_index)
        total
      else
        move_count = piece.valid_moves.size
        if piece.color == 'white'
          total + move_count
        else
          total - move_count
        end
      end
    end
  end
end
