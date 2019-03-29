class ThreatLogic
  def self.create_signature(new_pieces, game_turn_code)
    white_king = new_pieces.detect { |piece| piece.position_index == 29 }
    white_king_spaces = white_king.spaces_near_king
    black_king = new_pieces.detect { |piece| piece.position_index == 5 }
    black_king_spaces = black_king.spaces_near_king

    white_pieces = new_pieces.select { |piece| piece.color == 'white' }
    black_pieces = new_pieces.select { |piece| piece.color == 'black' }

    map_enemy_threats(white_king_spaces, black_pieces, new_pieces) +
    white_king.valid_moves(new_pieces).size.to_s +
    map_enemy_threats(black_king_spaces, white_pieces, new_pieces) +
    black_king.valid_moves(new_pieces).size.to_s +
    game_turn_code
  end

  def self.map_enemy_threats(spaces, enemy_pieces, new_pieces)
    enemy_pieces.select do |enemy_piece|
      (enemy_piece.valid_moves(new_pieces) & spaces).present?
    end.map do |enemy_piece|
      enemy_piece.find_piece_code + spaces.count do |space|
        enemy_piece.valid_moves(new_pieces).include?(space)
      end.to_s
    end.join('.')
  end
end
