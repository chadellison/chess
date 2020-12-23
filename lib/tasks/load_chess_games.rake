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

def ai_logic
  @ai_logic || AiLogic.new
end

def parse_file(file_number)
  start_time = Time.now
  games = PGN.parse(File.read("#{Rails.root}/training_data/game_set#{file_number}.pgn"))

  end_time = Time.now
  puts "PARSED #{games.size} GAMES IN #{end_time - start_time} SECONDS"
  start_time = Time.now
  all_games = []
  positions = []
  games.each { |game| create_positions(game.positions, game.result) }
  end_time = Time.now

  puts "loaded #{games.size} GAMES IN #{end_time - start_time} SECONDS"
end

def create_positions(game_positions, result)
  game_positions.each do |position|
    fen = position.to_fen
    fen_string = fen.to_s
    pieces_with_moves = ChessValidator::Engine.find_next_moves(fen_string).sort_by(&:piece_type)
    position = Position.create_position(fen_string)

    abstractions = ai_logic.create_abstractions(pieces_with_moves, position)

    abstractions.each do |abstraction|
      ResultHelper.update_results(abstraction, result)
      CacheService.hset(abstraction['type'], abstraction['signature'], abstraction)
    end

    position['abstractions'] = abstractions
    ResultHelper.update_results(position, result)
    CacheService.hset('positions', position['signature'], position)
  end
end
