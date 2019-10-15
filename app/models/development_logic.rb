class DevelopmentLogic
  def self.find_pattern(game_data)
    developed_pieces = game_data.pieces.select do |piece|
      piece.has_moved &&
        piece.enemy_targets.blank? &&
        !game_data.targets.include?(piece.position_index)
    end
    Signature.create_signature(developed_pieces, game_data.turn[0])
  end
end
