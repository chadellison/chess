desc 'Train on stockfish'
task train_on_stockfish: :environment do
  ENV['COUNT'].to_i.times do |game_number|
    game = Game.create
    start_time = Time.now
    engine = Stockfish::Engine.new('lib/stockfish-9-mac/Mac/stockfish-9-bmi2')
    engine.multipv(3)

    until game.outcome || game.moves.count > 200 do
      turn = game.current_turn
      game.reload_pieces if game.moves.count > 0
      if turn == stockfish_color(game_number)
        fen_notation = find_fen_notation(game)
        puts fen_notation
        stockfish_move = find_stockfish_move(fen_notation, engine)
        position_index = find_piece_index(game, stockfish_move)

        upgraded_type = find_upgraded_type(stockfish_move)

        game.move(position_index, stockfish_move[2..3], find_upgraded_type(stockfish_move[4]))
        puts game.moves.order(:move_count).last.value + ' ' + turn
      else
        game.ai_move
        puts game.moves.order(:move_count).last.value + ' ' + turn
      end
    end

    if game.outcome.present?
      game.moves.each do |move|
        move.setup.update(rank: (move.setup.rank + game.outcome))
      end
    end

    end_time = Time.now

    total_time = end_time - start_time

    puts "FINISHED GAME IN #{Time.at(total_time).utc.strftime("%H:%M:%S")}!"
    puts "OUTCOME:  #{game.outcome}"
    puts '---------------THE END---------------'
  end
end

def find_stockfish_move(fen_notation, engine)
  stockfish_result = engine.analyze(fen_notation, { depth: 12 })
  stockfish_result.split('bestmove').last.split('ponder').first.strip
end

def stockfish_color(game_number)
  game_number.even? ? 'white' : 'black'
end

def find_piece_index(game, stockfish_move)
  game.find_piece_by_position(stockfish_move[0..1]).position_index
end

def find_upgraded_type(stockfish_letter)
  if stockfish_letter.present?
    {
      'q' => 'queen',
      'r' => 'rook',
      'b' => 'bishop',
      'n' => 'knight'
      }[stockfish_letter]
  else
    ''
  end
end

def find_fen_notation(game)
  return 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1' if game.moves.blank?
  rows = ['8', '7', '6', '5', '4', '3', '2', '1']
  columns = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

  fen_notation = ''

  rows.each do |row|
    space_count = 0
    columns.each do |column|
      piece = game.find_piece_by_position(column + row)
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

  fen_notation += " #{game.current_turn[0]}"
  fen_notation += fen_castle_codes(game)
  fen_notation += fen_code_pawn_moved_two(game)
  fen_notation += ' 0'
  fen_notation += " #{game.moves.count / 2}"
  fen_notation
end

def fen_code_pawn_moved_two(game)
  last_move = game.moves.order(:move_count).last
  position_index = game.position_index_from_move(last_move.value)
  piece = game.find_piece_by_index(position_index)

  if game.pawn_moved_two?
    position_row = piece.color == 'black' ? piece.position[1].to_i + 1 : piece.position[1].to_i - 1
    " #{piece.position[0]}#{position_row}"
  else
    ' -'
  end
end

def fen_castle_codes(game)
  castle_codes = ''
  black_king = game.find_piece_by_index(5)
  black_king_rook = game.find_piece_by_index(32)
  black_queen_rook = game.find_piece_by_index(25)
  white_king = game.find_piece_by_index(29)
  white_king_rook = game.find_piece_by_index(32)
  white_queen_rook = game.find_piece_by_index(25)


  castle_codes += 'K' if white_king_rook.present? && [white_king, white_king_rook].none?(&:has_moved)
  castle_codes += 'Q' if white_queen_rook.present? && [white_king, white_queen_rook].none?(&:has_moved)
  castle_codes += 'k' if black_king_rook.present? && [black_king, black_king_rook].none?(&:has_moved)
  castle_codes += 'q' if black_queen_rook.present? && [black_king, black_queen_rook].none?(&:has_moved)
  castle_codes = '-' if castle_codes.blank?
  " #{castle_codes}"
end

def fen_piece_type(type, color)
  piece_key = {
    'king' => 'k',
    'queen' => 'q',
    'rook' => 'r',
    'bishop' => 'b',
    'knight' => 'n',
    'pawn' => 'p'
  }

  piece_type_code = piece_key[type]

  color == 'white' ? piece_type_code.capitalize : piece_type_code
end
