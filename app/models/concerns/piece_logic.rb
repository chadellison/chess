module PieceLogic
  extend ActiveSupport::Concern

  def find_piece_code
   code = { king: 'k', queen: 'q', rook: 'r', bishop: 'b', knight: 'n', pawn: 'p' }
      piece_code = code[piece_type.to_sym]
      color == 'white' ? piece_code.capitalize : piece_code
  end
end
