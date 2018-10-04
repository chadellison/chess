class ThreatSignature < ApplicationRecord
  validates_presence_of :signature
  validates_uniqueness_of :signature
  has_many :setups

  def self.create_signature(new_pieces, game_turn_code)
    white_king_spaces = new_pieces.detect { |piece| piece.position_index == 29 }.spaces_near_king
    black_king_spaces = new_pieces.detect { |piece| piece.position_index == 5 }.spaces_near_king

    black_pieces = new_pieces.select { |piece| piece.color == 'black' }
    white_pieces = new_pieces.select { |piece| piece.color == 'white' }

    white_threats = map_enemy_threats(white_king_spaces, black_pieces, new_pieces)
    black_threats = map_enemy_threats(black_king_spaces, white_pieces, new_pieces)
    game_threat_signature = white_threats + black_threats

    if game_threat_signature.present?
      game_threat_signature + game_turn_code
    end
  end

  def self.map_enemy_threats(spaces, enemy_pieces, new_pieces)
    enemy_pieces.select do |enemy_piece|
      (enemy_piece.valid_moves(new_pieces) & spaces).present?
    end.map do |enemy_piece|
      enemy_piece.find_piece_code + spaces.select { |space| enemy_piece.valid_moves(new_pieces).include?(space) }.join
    end.join('.')
  end
end
