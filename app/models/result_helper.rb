class ResultHelper
  def self.update_results(instance, result)
    case result
    when '1/2-1/2'
      instance['draws'] += 1
    when '1-0'
      instance['white_wins'] += 1
    when '0-1'
      instance['black_wins'] += 1
    end
  end
end
