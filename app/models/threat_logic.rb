class ThreatLogic
  def self.create_signature(new_pieces)
    white_king_spaces = king_by_index(new_pieces, 29)
    black_king_spaces = king_by_index(new_pieces, 5)

    white_pieces = pieces_by_color(new_pieces, 'white')
    black_pieces = pieces_by_color(new_pieces, 'black')

    map_enemy_threats(white_king_spaces, black_pieces, new_pieces) +
    map_enemy_threats(black_king_spaces, white_pieces, new_pieces)
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

  def self.pieces_by_color(new_pieces, color)
    new_pieces.select { |piece| piece.color == color }
  end

  def self.king_by_index(new_pieces, index)
    new_pieces.detect { |piece| piece.position_index == index }.spaces_near_king
  end
end
