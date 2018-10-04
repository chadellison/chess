class GeneralAttackSignature < ApplicationRecord
  validates_presence_of :signature
  validates_uniqueness_of :signature
  has_many :setups

  def self.create_signature(new_pieces, game_turn_code)
    signature = new_pieces.select { |piece| piece.enemy_targets.present? }.map do |piece|
      piece.find_piece_code
    end
    if signature.present?
      signature << game_turn_code
      signature.join('.')
    end
  end
end
