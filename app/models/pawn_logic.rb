class PawnLogic
  def self.create_signature(setup_data)
    pawns = setup_data.pieces.select { |piece| piece.piece_type == 'pawn' }
    pawns_by_color = pawns.group_by(&:color)

    if should_evaluate_pawn?(pawns_by_color)
      setup_data.calculate_piece_quality(pawns)
    else
      0
    end
  end

  def self.should_evaluate_pawn?(pawns_by_color)
    pawns_by_color['white'].present? &&
      pawns_by_color['black'].present? &&
      pawns_by_color['white'].count == pawns_by_color['black'].count
  end
end
