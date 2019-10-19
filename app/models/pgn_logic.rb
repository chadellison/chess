class PgnLogic
  def pgn_game(notation)
    PGN::Game.new(notation.to_s.split('.'))
  end

  def castle_data(notation)
    pgn_game(notation).positions.last.to_fen.to_s.split(' ')[-4]
  end

  def convert_to_fen(notation)
    pgn_game(notation).positions.last.to_fen
  end

  def en_passant_value(notation)
    pgn_game(notation).positions.last.to_fen.to_s.split(' ')[-3]
  end

  # def pieces_from_notation(notation)
  #   game_pieces = []
  #   pgn_game = pgn_logic.pgn_game(notation)
  #   board = pgn_game.positions.last.board
  #
  #   pgn_game.positions.last.board.squares.each_with_index do |column, ci|
  #     column.each_with_index do |square, ri|
  #       if square.present?
  #         piece = Piece.new({
  #           position: board.position_for([ci, ri]),
  #           piece_type: Piece.find_type(square),
  #           color: Piece.find_color(square),
  #         })
  #         game_pieces << piece
  #       end
  #     end
  #   end
  #   game_pieces
  # end
end
