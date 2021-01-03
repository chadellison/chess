class PositionData
  attr_reader :fen_notation, :engine, :pieces, :all_pieces, :next_pieces, :next_fen,
    :turn, :target_positions, :max_target_value

  def initialize(fen_notation)
    @fen_notation = fen_notation
    @engine = ChessValidator::Engine
    @pieces = @engine.find_next_moves(fen_notation)
    @all_pieces = @engine.pieces(fen_notation)
    @next_pieces = AbstractionHelper.next_pieces(fen_notation)
    @next_fen = AbstractionHelper.next_turn_fen(fen_notation)
    @turn = fen_notation.split[1]
    @target_positions = AbstractionHelper.find_target_positions(@pieces)
    @max_target_value = AbstractionHelper.max_target_value(pieces)
  end
end
