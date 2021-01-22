class Material
  def self.create_abstraction(position_data)
    # all_pieces = position_data.all_pieces
    # pieces = position_data.pieces
    # fen_notation = position_data.fen_notation
    #
    current_material_value = position_data.find_material_value(position_data.all_pieces)
    current_material_value = -current_material_value if position_data.turn == 'w'
    # (current_material_value + calculate_value(pieces, fen_notation, position_data)) * 0.1
    # position_data.max_target_value
    # if position_data.turn == 'w'
    current_material_value - position_data.max_target_value
    # else
    # end
  end

  # def self.calculate_value(pieces, fen_notation, position_data)
  #   max_material_gain = 0
  #   pieces.each do |piece|
  #     piece.targets.each do |target|
  #       capture_value = position_data.find_piece_value(target)
  #
  #       new_fen_notation = position_data.engine.move(piece, target.position, fen_notation)
  #       new_pieces = position_data.engine.find_next_moves(new_fen_notation)
  #       max_recapture_value = position_data.max_target_value
  #
  #       material_gain = capture_value - max_recapture_value
  #       max_material_gain = material_gain if material_gain > max_material_gain
  #     end
  #   end
  #   -max_material_gain
  # end
end
