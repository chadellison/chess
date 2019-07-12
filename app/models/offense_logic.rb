class OffenseLogic
  def self.create_signature(game_data)
    game_data[:pieces].reduce(0) do |total, piece|
      if piece.color == 'white' && piece.position[1].to_i > 4
        total + 1
      elsif piece.color == 'black' && piece.position[1].to_i < 5
        total - 1
      else
        total
      end
    end
  end
end
