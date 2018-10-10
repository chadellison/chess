class MaterialSignature < ApplicationRecord
  validates_presence_of :signature
  validates_uniqueness_of :signature
  has_many :setups

  def self.create_signature(new_pieces, game_turn_code)
    new_pieces.map(&:find_piece_code).join + game_turn_code
  end
end
