module FenNotationLogic
  extend ActiveSupport::Concern

  NEW_BOARD = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

  def find_fen_notation
    return NEW_BOARD if moves.blank?
    fen_piece_positions + fen_game_data
  end

  def fen_piece_positions
    fen_notation = ''

    ('1'..'8').to_a.reverse.each do |row|
      space_count = 0
      ('a'..'h').each do |column|
        piece = find_piece_by_position(column + row)
        if piece.present?
          fen_notation += space_count.to_s if space_count > 0
          space_count = 0
          fen_notation += fen_piece_type(piece.piece_type, piece.color)
        else
          space_count += 1
          fen_notation += space_count.to_s if column == 'h'
        end
      end
      fen_notation += '/' unless row == '1'
    end

    fen_notation
  end

  def fen_game_data
    " #{current_turn[0]}" +
      fen_castle_codes +
      fen_code_pawn_moved_two +
      ' 0' +
      " #{moves.count / 2}"
  end

  def fen_code_pawn_moved_two
    last_move = moves.order(:move_count).last
    position_index = position_index_from_move(last_move.value)
    piece = find_piece_by_index(position_index)

    if pawn_moved_two?
      position_row = piece.color == 'black' ? piece.position[1].to_i + 1 : piece.position[1].to_i - 1
      " #{piece.position[0]}#{position_row}"
    else
      ' -'
    end
  end

  def fen_castle_codes
    castle_codes = ''
    black_king = find_piece_by_index(5)
    black_king_rook = find_piece_by_index(8)
    black_queen_rook = find_piece_by_index(1)
    white_king = find_piece_by_index(29)
    white_king_rook = find_piece_by_index(25)
    white_queen_rook = find_piece_by_index(32)

    castle_codes += 'K' if white_king_rook.present? && [white_king, white_king_rook].none?(&:has_moved)
    castle_codes += 'Q' if white_queen_rook.present? && [white_king, white_queen_rook].none?(&:has_moved)
    castle_codes += 'k' if black_king_rook.present? && [black_king, black_king_rook].none?(&:has_moved)
    castle_codes += 'q' if black_queen_rook.present? && [black_king, black_queen_rook].none?(&:has_moved)
    castle_codes = '-' if castle_codes.blank?
    " #{castle_codes}"
  end

  def fen_piece_type(type, color)
    piece_key = {
      king: 'k', queen: 'q', rook: 'r', bishop: 'b', knight: 'n', pawn: 'p'
    }

    piece_type_code = piece_key[type.to_sym]

    color == 'white' ? piece_type_code.capitalize : piece_type_code
  end
end
