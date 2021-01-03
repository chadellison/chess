class Attack
  def self.create_evade_abstraction(pieces)
    -AbstractionHelper.max_target_value(pieces) * 0.1
  end

  def self.tempo_abstraction(position_data)
    value = 0

    position_data.next_pieces.each do |piece|
      if !position_data.target_positions.include?(piece.position)
        piece_value = AbstractionHelper.find_piece_value(piece)
        max_opponent_value = AbstractionHelper.max_value(piece.targets, 0)
        difference = max_opponent_value - piece_value
        value = difference if difference > value
      end
    end
    value
  end

  def self.undefended_abstraction(position_data)
    # max attack of undefended pieces
  end

  # def self.create_attack_abstraction(position_data)
  #   targets = find_targets(position_data.pieces)
  #   max_vulnerability = AbstractionHelper.max_value(targets, 0)
  #
  #   attack_value = 0
  #   position_data.next_pieces.each do |attacker|
  #     if targets.none? { |target| target.position == attacker.position }
  #       max = AbstractionHelper.max_value(attacker.targets, 0)
  #       value = max - max_vulnerability
  #       attack_value = value if value > attack_value
  #     end
  #   end
  #   attack_value
  # end

  # def self.find_targets(pieces)
  #   pieces.reduce([]) do |accumulator, piece|
  #     accumulator + piece.targets
  #   end
  # end
end
