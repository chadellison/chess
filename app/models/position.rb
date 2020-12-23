class Position
  def self.create_position(fen_notation)
    fen_array = fen_notation.split
    signature = "#{fen_array[0]} #{fen_array[1]} #{fen_array[2]} #{fen_array[3]}"

    position = CacheService.hget('positions', signature)
    if position.present?
      position
    else
      {
        'signature' => signature,
        'white_wins' => 0,
        'black_wins' => 0,
        'draws' => 0,
        'type' => 'position'
      }
    end
  end
end
