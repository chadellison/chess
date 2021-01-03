class Activity
  def self.create_abstraction(position_data)
    pieces = position_data.pieces
    new_pieces = position_data.next_pieces
    
    if in_check?(new_pieces)
      0
    else
      move_count = count_moves(pieces, new_pieces)
      next_move_count = count_moves(new_pieces, pieces)
      (next_move_count - move_count) * 0.1
    end
  end

  def self.count_moves(first_set, second_set)
    first_set.reduce(0) do |sum, piece|
      move_count = piece.valid_moves.count do |move|
        second_set.none? do |next_piece|
          if next_piece.piece_type.downcase == 'p'
            AbstractionHelper.pawn_attack(next_piece).include?(move)
          else
            next_piece.valid_moves.include?(move)
          end
        end
      end
      sum + move_count
    end
  end

  def self.in_check?(pieces)
    pieces.any? do |piece|
      piece.targets.any? { |target| target.piece_type.downcase == 'k'}
    end
  end
end
