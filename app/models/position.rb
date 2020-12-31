class Position
  def self.create_position(fen_notation)
    fen_array = fen_notation.split
    signature = "#{fen_array[0]} #{fen_array[1]} #{fen_array[2]} #{fen_array[3]}"

    position = CacheService.hget('positions', signature)
    if position.present?
      position
    else
      # pieces_with_moves = ChessValidator::Engine.find_next_moves(fen_notation)
      #                                           .sort_by(&:piece_type)

      # abstractions = create_abstractions(pieces_with_moves, signature)
      {
        'signature' => signature,
        'white_wins' => 0,
        'black_wins' => 0,
        'draws' => 0,
        'type' => 'position',
        # 'abstractions' => abstractions
      }
    end
  end

  # def self.create_abstractions(pieces, signature)
  #   fen_notation = signature + ' 0 1'
  #   all_pieces = ChessValidator::Engine.pieces(fen_notation).sort_by(&:piece_type)
  #   next_pieces = AbstractionHelper.next_pieces(fen_notation)
  #   [
  #     Activity.create_abstraction(pieces, next_pieces),
  #     Material.create_abstraction(all_pieces, pieces, fen_notation),
  #     Attack.create_evade_abstraction(pieces),
  #     Attack.create_attack_abstraction(pieces, next_pieces),
  #     King.create_abstraction(pieces, next_pieces, all_pieces),
  #   ]
  # end
end
