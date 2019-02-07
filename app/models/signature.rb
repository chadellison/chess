class Signature < ApplicationRecord
  validates_presence_of :value
  validates_uniqueness_of :value
  has_many :setup_signatures
  has_many :setups, through: :setup_signatures

  def self.create_signature(type, new_pieces, game_turn_code)
    signature_value = write_signature(type, new_pieces)
    if signature_value.present?
      Signature.find_or_create_by(
        signature_type: type,
        value: signature_value + game_turn_code
      )
    end
  end

  def self.write_signature(type, new_pieces)
    case type
    when 'material'
      MaterialSignature.create_signature(new_pieces)
    when 'activity'
      ActivitySignature.create_signature(new_pieces)
    when 'white_threat'
      ThreatLogic.create_threat_signature(new_pieces, 'white')
    when 'black_threat'
      ThreatLogic.create_threat_signature(new_pieces, 'black')
    when 'white_pawn_attack'
      AttackLogic.create_attack_signature(new_pieces, (17..24).to_a)
    when 'black_pawn_attack'
      AttackLogic.create_attack_signature(new_pieces, (9..16).to_a)
    when 'white_knight_attack'
      AttackLogic.create_attack_signature(new_pieces, [26, 31])
    when 'black_knight_attack'
      AttackLogic.create_attack_signature(new_pieces, [2, 7])
    when 'white_bishop_attack'
      AttackLogic.create_attack_signature(new_pieces, [27, 30])
    when 'black_bishop_attack'
      AttackLogic.create_attack_signature(new_pieces, [3, 6])
    when 'white_rook_attack'
      AttackLogic.create_attack_signature(new_pieces, [25, 32])
    when 'black_rook_attack'
      AttackLogic.create_attack_signature(new_pieces, [1, 8])
    when 'white_queen_attack'
      AttackLogic.create_attack_signature(new_pieces, [28])
    when 'black_queen_attack'
      AttackLogic.create_attack_signature(new_pieces, [4])
    when 'white_king_attack'
      AttackLogic.create_attack_signature(new_pieces, [29])
    when 'black_king_attack'
      AttackLogic.create_attack_signature(new_pieces, [5])
    end
  end
end
