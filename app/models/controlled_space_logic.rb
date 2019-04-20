class ControlledSpaceLogic
  def self.create_signature(new_pieces, game_turn_code)
    empty_squares = squares - new_pieces.map(&:position)

    empty_squares.reduce(0) do |total, empty_square|
      new_pieces.each do |piece|
        if piece.valid_moves(new_pieces).include?(empty_square)
          if piece.color == 'white'
            total + 1
          else
            total - 1
          end
        end
      end
      total
    end.to_s + game_turn_code
  end

  def self.squares
    columns = ('1'..'8')
    ('a'..'h').map do |row|
      columns.map { |column| row + column }
    end.flatten
  end
end
