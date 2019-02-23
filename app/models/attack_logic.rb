class AttackLogic
  def self.create_signature(new_pieces)
    new_pieces.select { |piece| piece.enemy_targets.present? }.map do |piece|
      piece.find_piece_code + 'x' + piece.enemy_targets.map do |enemy_target|
        enemy_target.to_s + 'o' + Piece.defenders(enemy_target, new_pieces).map do |defender|
          defender.find_piece_code
        end.join('.')
      end.join
    end.join
  end
end
