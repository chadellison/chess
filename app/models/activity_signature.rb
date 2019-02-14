class ActivitySignature
  def self.create_signature(new_pieces)
    signature = {}
    new_pieces.each do |piece|
      signature[piece.position_index] = piece.valid_moves(new_pieces).count
    end

    signature.map do |index, count|
      "#{index}-#{count}"
    end.join('.')
  end
end
