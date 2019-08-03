class CheckLogic
  def self.create_signature(setup_data)
    king_attackers = setup_data.pieces.select do |piece|
      piece.enemy_targets.include?(5) || piece.enemy_targets.include?(29)
    end

    king_attackers.reduce(0) do |sum, piece|
      if !setup_data.targets.include?(piece.position_index)
        if piece.color == 'white'
          sum + 1
        else
          sum - 1
        end
      else
        sum
      end
    end
  end
end
