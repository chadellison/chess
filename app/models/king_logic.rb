class KingLogic
  def self.create_signature(setup_data)
    kings = setup_data.pieces.select { |piece| piece.piece_type == 'king' }
    # do things here
  end
end
