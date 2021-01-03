class Attack
  def self.create_evade_abstraction(position_data)
    -position_data.max_target_value * 0.1
  end

  def self.create_abstraction(position_data)
    max_target_gain = 0
    max_vulnerability = position_data.max_target_value
    position_data.next_pieces.each do |piece|
      if piece.targets.present? && !position_data.target_positions.include?(piece.position)
        piece.targets.each do |target|
          if target.piece_type.downcase != 'k'
            final_fen = position_data.engine.move(piece, target.position, position_data.next_fen)
            pieces_with_moves = position_data.engine.find_next_moves(final_fen)
            target_value = position_data.find_piece_value(target)
            if pieces_with_moves.none? { |piece| piece.valid_moves.include?(target.position) }
              difference = target_value - max_vulnerability
            else
              piece_value = position_data.find_piece_value(piece)
              difference = target_value - (piece_value + max_vulnerability)
            end
            max_target_gain = difference if difference > max_target_gain
          end
        end
      end
    end

    max_target_gain
  end
end
