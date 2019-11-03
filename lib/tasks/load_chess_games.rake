desc "load_chess_games"
task load_chess_games: :environment do
  first_file_num = 1
  last_file_num = 72

  range_args = ARGV[1]

  if range_args != nil && range_args != '' && range_args.include?('-')
    range = range_args.split('-')

    first_file_num = range[0].to_i
    last_file_num = range[1].to_i
  end

  chess_file_numbers = (first_file_num..last_file_num).to_a

  puts "---------------LOADING #{first_file_num}-#{last_file_num} GAME FILES---------------"

  while chess_file_numbers.present?
    file_number = chess_file_numbers.pop
    parse_file(file_number)
  end

  puts '---------------GAMES LOADED---------------'
end

def parse_file(file_number)
  file_path = "#{Rails.root}/training_data/game_set#{file_number}.pgn"
  PGN.parse(File.read(file_path)).each do |pgn_game|
    notation = pgn_game.moves.map(&:notation).join('.')
    outcome = find_outcome(pgn_game.result)
    setups = pgn_game.positions.map do |position|
      setup = Setup.find_setup(position.to_fen)
      setup.update_outcomes(outcome)
      REDIS.set('setup_' + setup.position_signature, SetupSerializer.serialize(setup))
    end

    puts 'OUTCOME: ' + outcome
  end
end

def find_outcome(result)
  case result
  when '0-1' then BLACK_WINS
  when '1-0' then WHITE_WINS
  else DRAW
  end
end
