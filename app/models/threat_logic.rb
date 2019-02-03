class ThreatLogic
  def self.create_threat_signature(new_pieces, game_turn_code, color)
    king_spaces = new_pieces.detect { |piece| piece.position_index == 29 }.spaces_near_king

    enemy_pieces = new_pieces.select { |piece| piece.color == color }

    threats = map_enemy_threats(king_spaces, enemy_pieces, new_pieces)

    if threats.present?
      threats + game_turn_code
    end
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
