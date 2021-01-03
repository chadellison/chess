desc "load_chess_games"
task load_chess_games: :environment do
  first_file_num = 1
  last_file_num = 72

  range_args = ENV['RANGE']

  if range_args.blank? || !range_args.include?('-')
    puts 'Please specify the range of files you would like to load in the following format: RANGE=1-7'
  else
    range = range_args.split('-')

    first_file_num = range[0].to_i
    last_file_num = range[1].to_i
    puts "---------------LOADING #{first_file_num}-#{last_file_num} GAME FILES---------------"
    (first_file_num..last_file_num).each do |file_number|
      parse_file(file_number)
    end

    puts '---------------GAMES LOADED---------------'
  end
end

def parse_file(file_number)
  start_time = Time.now
  games = PGN.parse(File.read("#{Rails.root}/training_data/game_set#{file_number}.pgn"))
  end_time = Time.now
  puts "PARSED #{games.size} GAMES IN #{end_time - start_time} SECONDS"
  start_time = Time.now
  games.each { |game| create_positions(game.positions, game.result) }
  end_time = Time.now
  puts "loaded #{games.size} GAMES IN #{end_time - start_time} SECONDS"
end

def create_positions(game_positions, result)
  game_positions.each do |position|
    fen = position.to_fen
    fen_string = fen.to_s
    position = Position.create_position(fen_string)
    Position.update_results(position, result)
    CacheService.hset('positions', position['signature'], position)
  end
end
