class KingLogic
  def self.create_signature(game_data)
    kings = game_data.pieces.select { |piece| piece.piece_type == 'king' }
    # do things here
  end
end
