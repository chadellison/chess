class AttackLogic
  def self.create_attack_signature(new_pieces, piece_code)
    attack_count = new_pieces.reduce(0) do |sum, piece|
      sum + piece.enemy_targets(piece_code).count
    end

    spaces = []
    new_pieces.each do |piece|
      if piece.find_piece_code == piece_code
        spaces.push(piece.position)
      end
    end

    defense_count = new_pieces.reduce(0) do |sum, piece|
      sum + spaces.count { |space| piece.defend?(space, new_pieces) }
    end

    (defense_count - attack_count).to_s
  end
end
