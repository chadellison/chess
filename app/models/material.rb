class Material
  def self.create_abstraction(all_pieces, pieces, fen_notation)
    current_material_value = AbstractionHelper.find_material_value(all_pieces)
    current_material_value = -current_material_value if fen_notation.split[1] == 'w'
    (current_material_value + calculate_value(pieces, fen_notation)) * 0.1
  end

  def self.calculate_value(pieces, fen_notation)
    max_material_gain = 0
    pieces.each do |piece|
      piece.targets.each do |target|
        capture_value = AbstractionHelper.find_piece_value(target)

        new_fen_notation = ChessValidator::Engine.move(piece, target.position, fen_notation)
        new_pieces = ChessValidator::Engine.find_next_moves(new_fen_notation)
        max_recapture_value = AbstractionHelper.max_target_value(pieces)

        material_gain = capture_value - max_recapture_value
        max_material_gain = material_gain if material_gain > max_material_gain
      end
    end
    -max_material_gain
  end
end
