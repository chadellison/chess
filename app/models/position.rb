class Position
  def self.create_position(fen_notation)
    fen_array = fen_notation.split
    signature = "#{fen_array[0]} #{fen_array[1]}".gsub('/', 'z')

    # king_snapshot ???
    position = CacheService.hget('positions', signature)
    if position.present?
      position
    else
      {
        'signature' => signature,
        'white_wins' => 0,
        'black_wins' => 0,
        'draws' => 0,
        'type' => 'position',
      }
    end
  end

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
