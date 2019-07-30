class CheckLogic
  def self.create_signature(game_data)
    king_attackers = game_data.pieces.select do |piece|
      piece.enemy_targets.include?(5) || piece.enemy_targets.include?(29)
    end

    king_attackers.reduce(0) do |sum, piece|
      if !game_data.targets.include?(piece.position_index)
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
