class ActivityLogic
  def self.create_signature(new_pieces)
    targets = new_pieces.map(&:enemy_targets).flatten
    return 0 if targets.any? { |target| [5, 29].include?(target) }
    
    new_pieces.reduce(0) do |total, piece|
      move_count = piece.valid_moves.size
      if piece.color == 'white'
        total + move_count
      else
        total - move_count
      end
    end
  end
end
