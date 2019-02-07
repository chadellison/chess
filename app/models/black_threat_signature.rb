# class BlackThreatSignature < ApplicationRecord
#   validates_presence_of :signature
#   validates_uniqueness_of :signature
#   has_many :setups
#
#   def self.create_signature(new_pieces, game_turn_code)
#     ThreatLogic.create_threat_signature(new_pieces, game_turn_code, 'black')
#   end
# end
