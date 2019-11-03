class GameData
  attr_reader :pieces, :targets, :fen_data, :turn

  def initialize(pieces, fen_data)
    @pieces = pieces
    @fen_data = fen_data
    @turn = fen_data.active == 'w' ? 'white' : 'black'
    @targets = pieces.map(&:enemy_targets).flatten
  end

  def opponent_color
    turn == 'white' ? 'black' : 'white'
  end

  def opponent_king
    @opponent_king ||= opponents.detect { |piece| piece.piece_type == 'king' }
  end

  def ally_king
    @ally_king ||= allies.detect { |piece| piece.piece_type == 'king' }
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
    allies.select { |ally| ally.enemy_targets.present? }
  end

  def ally_targets
    target_pieces.select { |target_piece| target_piece == turn }
  end

  def opponent_targets
    target_pieces.select { |target_piece| target_piece == opponent_color }
  end
end
