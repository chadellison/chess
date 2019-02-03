class AttackLogic
  def self.create_attack_signature(new_pieces, game_turn_code, color)
    signature = new_pieces.select do |piece|
      piece.color == color && piece.enemy_targets.present?
    end.map { |piece| piece.find_piece_code + 'x' + piece.enemy_targets.join('x') }

    if signature.present?
      signature << game_turn_code
      signature.join('.')
    end
  end
end
