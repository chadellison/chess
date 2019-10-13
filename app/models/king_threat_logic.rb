class KingThreatLogic
  def self.find_pattern(game_data)
    kings = game_data.pieces.select { |piece| piece.piece_type == 'king' }
    spaces_near_kings = kings.map(&:spaces_near_king)

    near_king_ids = game_data.pieces.select do |piece|
      spaces_near_kings.include?(piece.position)
    end.map(&:position_index)

    defender_ids = []
    near_king_ids.each do |position_index|
      defenders += Piece.defenders(position_index, game_data.pieces).map(&:position_index)
    end

    involved_in_threat = game_data.pieces.select do |piece|
      (piece.valid_moves & spaces_near_kings).size > 0 ||
        defender_ids.include?(piece.position_index)
    end.uniq

    Signature.create_signature(involved_in_threat, game_data.turn[0])
  end
end
