class ThreatLogic
  def self.create_threat_signature(new_pieces, color)
    king_spaces = new_pieces.detect { |piece| piece.position_index == 29 }.spaces_near_king

    enemy_pieces = new_pieces.select { |piece| piece.color == color }

    map_enemy_threats(king_spaces, enemy_pieces, new_pieces)
  end

  def self.map_enemy_threats(spaces, enemy_pieces, new_pieces)
    enemy_pieces.select do |enemy_piece|
      (enemy_piece.valid_moves(new_pieces) & spaces).present?
    end.map do |enemy_piece|
      enemy_piece.find_piece_code + spaces.select do |space|
        enemy_piece.valid_moves(new_pieces).include?(space)
      end.join
    end.join('.')
  end
end
