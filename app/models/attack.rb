class Attack
  def self.create_evade_abstraction(pieces)
    -AbstractionHelper.max_target_value(pieces) * 0.1
  end

  def self.create_attack_abstraction(pieces, next_attackers)
    targets = find_targets(pieces)
    max_vulnerability = AbstractionHelper.max_value(targets, 0)

    attack_value = 0
    next_attackers.each do |attacker|
      if targets.none? { |target| target.position == attacker.position }
        max = AbstractionHelper.max_value(attacker.targets, 0)
        value = max - max_vulnerability
        attack_value = value if value > attack_value
      end
    end
    attack_value
  end

  # def self.multiple_attack_abstraction(pieces, next_attackers)
  #   unique_targets = find_targets(next_attackers).uniq
  #   threat_value = AbstractionHelper.max_target_value(pieces)
  #   if unique_targets.size > 1
  #     min = AbstractionHelper.min_target_value(unique_targets)
  #     min - threat_value
  #   else
  #     0
  #   end
  # end

  def self.find_targets(pieces)
    pieces.reduce([]) do |accumulator, piece|
      accumulator + piece.targets
    end
  end
end
