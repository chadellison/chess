class AttackLogic
  def self.create_attack_signature(new_pieces, position_indices)
    signature = {}
    color = position_indices.max <= 16 ? 'black' : 'white'

    new_pieces.each do |piece|
      position_indices.each do |index|
        if piece.enemy_targets(index.to_s).present?
          update_attack_count(signature, index, 1)
        end
      end
    end

    new_pieces.select { |piece| piece.color == color }.each do |piece|
      signature.each do |index, attack_count|
        if piece.defend?(index, new_pieces)
          update_attack_count(signature, index, -1)
        end
      end
    end

    signature.map { |index, attack_count| index.to_s + attack_count.to_s }.join('.')
  end

  def self.update_attack_count(signature, key, value)
    if signature[key].present?
      signature[key] += value
    else
      signature[key] = value
    end
  end
end
