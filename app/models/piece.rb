class Piece
  include MoveLogic

  PIECE_CODE = { king: 'k', queen: 'q', rook: 'r', bishop: 'b', knight: 'n', pawn: 'p' }
  PIECE_VALUE = { king: 10, queen: 9, rook: 5, bishop: 3, knight: 3, pawn: 1 }

  attr_accessor :piece_type, :color, :position, :position_index, :moved_two,
    :has_moved, :valid_moves, :enemy_targets, :game_move_logic

  def self.defenders(index, game_pieces)
    target_piece = game_pieces.detect { |piece| piece.position_index == index }
    square = target_piece.position

    game_pieces.select do |piece|
      target_piece.color == piece.color &&
        piece.moves_for_piece.include?(square) &&
        piece.valid_move_path?(square, game_pieces.map(&:position)) &&
        piece.valid_for_piece?(square, game_pieces) &&
        Piece.king_is_safe?(
          piece.color,
          piece.game_move_logic.pieces_with_next_move(
            game_pieces, piece.position_index.to_s + square
          )
        )
    end
  end

  def self.new_piece(piece, new_position, upgraded_type)
    new(
      position_index: piece.position_index,
      position: new_position,
      has_moved: true,
      piece_type: (upgraded_type.present? ? upgraded_type : piece.piece_type)
    )
  end

  def self.king_is_safe?(allied_color, game_pieces)
    king = game_pieces.detect do |piece|
      piece.piece_type == 'king' && piece.color == allied_color
    end

    return false if king.blank?

    occupied_spaces = game_pieces.map(&:position)
    opponent_pieces = game_pieces.reject { |piece| piece.color == allied_color }

    opponent_pieces.none? do |piece|
      piece.moves_for_piece.include?(king.position) &&
        piece.valid_move_path?(king.position, occupied_spaces) &&
        piece.valid_destination?(king.position, game_pieces) &&
        (piece.piece_type != 'pawn' || piece.valid_for_pawn?(king.position, game_pieces))
    end
  end

  def initialize(attributes = {})
    @piece_type = attributes[:piece_type]
    @color = attributes[:color]
    @position = attributes[:position]
    @position_index = attributes[:position_index]
    @has_moved = attributes[:has_moved]
    @moved_two = attributes[:moved_two]
    @enemy_targets = []
    @valid_moves = []
    @game_move_logic = GameMoveLogic.new
  end

  def valid_move?(game_pieces, move)
    new_pieces = game_move_logic.pieces_with_next_move(game_pieces, position_index.to_s + move)
    valid_move_path?(move, game_pieces.map(&:position)) &&
      valid_destination?(move, game_pieces) &&
      valid_for_piece?(move, game_pieces) &&
      Piece.king_is_safe?(color, new_pieces)
  end

  def find_piece_code
    piece_code = PIECE_CODE[piece_type.to_sym]
    color == 'white' ? piece_code.capitalize : piece_code
  end

  def find_piece_value
    PIECE_VALUE[piece_type.to_sym]
  end
end
