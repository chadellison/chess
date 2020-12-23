class Space
  def self.create_signature(pieces)
    pieces.sort_by { |piece| piece.position }.map do |piece|
      piece.color + piece.position
    end.join
  end
end
