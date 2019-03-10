class Piece
  include MoveLogic

  PIECE_CODE = { king: 'k', queen: 'q', rook: 'r', bishop: 'b', knight: 'n', pawn: 'p' }
  PIECE_VALUE = { king: 0, queen: 9, rook: 5, bishop: 3, knight: 3, pawn: 1 }

  attr_accessor :game_id, :piece_type, :color, :position, :position_index,
    :moved_two, :has_moved, :valid_moves, :enemy_targets

  def self.defenders(index, game_pieces)
    target_piece = game_pieces.detect { |piece| piece.position_index == index }
    square = target_piece.position
    destination_color = target_piece.color

    game_pieces.select do |piece|
      [
        target_piece.color == piece.color,
        piece != target_piece,
        piece.valid_move_path?(square, game_pieces.map(&:position)),
        piece.valid_for_piece?(square, game_pieces),
        piece.king_is_safe?(piece.color, Game.pieces_with_next_move(game_pieces, piece.position_index.to_s + square))
      ].all?
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

  def initialize(attributes = {})
    @piece_type = attributes[:piece_type]
    @color = attributes[:color]
    @position = attributes[:position]
    @position_index = attributes[:position_index]
    @game_id = attributes[:game_id]
    @has_moved = attributes[:has_moved]
    @moved_two = attributes[:moved_two]
    @enemy_targets = []
  end

  def moves_for_piece
    case piece_type
    when 'rook'
      moves_for_rook
    when 'bishop'
      moves_for_bishop
    when 'queen'
      moves_for_queen
    when 'king'
      moves_for_king
    when 'knight'
      moves_for_knight
    when 'pawn'
      moves_for_pawn
    end
  end

  def valid_moves(game_pieces)
    @valid_moves ||= moves_for_piece.select do |move|
      if valid_move?(game_pieces, move)
        load_enemy_targets(move, game_pieces)
        true
      end
    end
  end

  def valid_move?(game_pieces, move)
    [
      valid_move_path?(move, game_pieces.map(&:position)),
      valid_destination?(move, game_pieces),
      valid_for_piece?(move, game_pieces),
      king_is_safe?(color, Game.pieces_with_next_move(game_pieces, position_index.to_s + move))
    ].all?
  end

  def load_enemy_targets(move, game_pieces)
    destination_piece = game_pieces.detect { |piece| piece.position == move }
    if destination_piece.present?
      @enemy_targets.push(destination_piece.position_index)
    end
  end

  def game
    @game ||= Game.find(game_id)
  end

  def find_piece_code
    piece_code = PIECE_CODE[piece_type.to_sym]
    color == 'white' ? piece_code.capitalize : piece_code
  end

  def find_piece_value
    PIECE_VALUE[piece_type.to_sym]
  end
end
