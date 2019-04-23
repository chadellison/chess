class ThreatLogic
  def self.create_signature(new_pieces, game_turn_code)
    king_indices = [5, 29]
    white_king = nil
    black_king = nil

    king_spaces = new_pieces.select do |piece|
      black_king = piece if piece.position_index == 5
      white_king = piece if piece.position_index == 29
      king_indices.include?(piece.position_index)
    end.map(&:spaces_near_king).flatten

    ControlledSpaceLogic.controlled_ratio(king_spaces, new_pieces)
      .to_s + game_turn_code
  end
end
