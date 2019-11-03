class PieceQualityLogic
  TOTAL_SCORE = 5
  def self.find_pattern(game_data, piece_index)
    focus_piece = game_data.pieces.detect do |piece|
      piece.position_index == piece_index
    end

    return 0 if focus_piece.blank?

    enemy_territory = false
    enemy_territory = true if focus_piece.position[1].to_i > 4 && focus_piece.color == 'white'
    enemy_territory = true if focus_piece.position[1].to_i < 5 && focus_piece.color == 'black'

    quality_score = 0
    quality_score += 1 if focus_piece.has_moved
    quality_score += 1 if enemy_territory
    quality_score += 1 if !game_data.targets.include?(piece_index)
    quality_score += 1 if focus_piece.enemy_targets.present?
    quality_score += 1 if focus_piece.valid_moves.present?
    return 0 if quality_score == 0

    value = (quality_score.to_f / TOTAL_SCORE.to_f).round(1)
    value = (1 - value) if focus_piece.color != game_data.turn
    value
  end
end
