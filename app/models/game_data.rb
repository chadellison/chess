class GameData
  attr_reader :move, :pieces, :turn, :material_value, :targets

  def initialize(move, pieces, turn, material_value)
    @move = move
    @pieces = pieces
    @material_value = material_value
    @turn = turn
    @targets = pieces.map(&:enemy_targets).flatten
  end

  # def defender_index
  #   if @defender_index.present?
  #     @defender_index
  #   else
  #     @defender_index = {}
  #     pieces.each do |piece|
  #       key = piece.position_index
  #       @defender_index[key] = Piece.defenders(key, pieces)
  #     end
  #     @defender_index
  #   end
  # end

  def opponent_color
    turn == 'white' ? 'black' : 'white'
  end

  def opponents
    @opponents ||= pieces.select { |piece| piece.color != turn }
  end

  def allies
    @allies ||= pieces.select { |piece| piece.color == turn }
  end

  def target_pieces
    @target_pieces ||= pieces.select { |piece| targets.include?(piece.position_index) }
  end

  def ally_attackers
    @ally_attackers ||= allies.select { |ally| ally.enemy_targets.present? }
  end

  def opponent_attackers
    @opponent_attackers ||= opponents.select do |opponent|
      opponent.enemy_targets.present?
    end
  end

  def ally_targets
    @ally_targets ||= target_pieces.select { |target_piece| target_piece.color == turn }
  end

  def opponent_targets
    @opponent_targets ||= target_pieces.select { |target_piece| target_piece.color == opponent_color }
  end

  def pawns
    @pawns ||= pieces.select { |piece| piece.piece_type == 'pawn' }
  end

  def kings
    @kings ||= pieces.select { |piece| piece.piece_type == 'king' }
  end

  def duplicated_targets
    @duplicated_targets ||= targets.map do |target_id|
      target_pieces.detect { |target| target.position_index == target_id }
    end
  end

  def non_targeted_ally_attackers
    @non_targeted_ally_attackers ||= ally_attackers.select do |ally|
      !targets.include?(ally.position_index)
    end
  end

  def moved_piece
    if @moved_piece.present?
      @moved_piece
    else
      last_moved_index = move.value.to_i
      @moved_piece = allies.detect do |ally|
        ally.position_index == last_moved_index
      end
      @moved_piece
    end
  end
end
