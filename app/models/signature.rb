class Signature < ApplicationRecord
  validates_presence_of :value
  validates_uniqueness_of :value
  has_many :setup_signatures
  has_many :setups, through: :setup_signatures

  def self.create_signature(type, new_pieces, game_turn_code)
    signature_value = write_signature(type, new_pieces, game_turn_code)
    Signature.find_or_create_by(signature_type: type, value: signature_value)
  end

  def self.write_signature(type, new_pieces, game_turn_code)
    case type
    when 'material'
      MaterialSignature.create_signature(new_pieces, game_turn_code)
    when 'activity'
      ActivitySignature.create_signature(new_pieces, game_turn_code)
    when 'white_threat'
      ThreatLogic.create_threat_signature(new_pieces, game_turn_code, 'white')
    when 'black_threat'
      ThreatLogic.create_threat_signature(new_pieces, game_turn_code, 'black')
    when 'white_pawn_attack'
      AttackLogic.create_attack_signature(new_pieces, (17..24).to_a, game_turn_code)
    when 'black_pawn_attack'
      AttackLogic.create_attack_signature(new_pieces, (9..16).to_a, game_turn_code)
    when 'white_knight_attack'
      AttackLogic.create_attack_signature(new_pieces, [26, 31], game_turn_code)
    when 'black_knight_attack'
      AttackLogic.create_attack_signature(new_pieces, [2, 7], game_turn_code)
    when 'white_bishop_attack'
      AttackLogic.create_attack_signature(new_pieces, [27, 30], game_turn_code)
    when 'black_bishop_attack'
      AttackLogic.create_attack_signature(new_pieces, [3, 6], game_turn_code)
    when 'white_rook_attack'
      AttackLogic.create_attack_signature(new_pieces, [25, 32], game_turn_code)
    when 'black_rook_attack'
      AttackLogic.create_attack_signature(new_pieces, [1, 8], game_turn_code)
    when 'white_queen_attack'
      AttackLogic.create_attack_signature(new_pieces, [28], game_turn_code)
    when 'black_queen_attack'
      AttackLogic.create_attack_signature(new_pieces, [4], game_turn_code)
    when 'white_king_attack'
      AttackLogic.create_attack_signature(new_pieces, [29], game_turn_code)
    when 'black_king_attack'
      AttackLogic.create_attack_signature(new_pieces, [5], game_turn_code)
    end
  end
end
