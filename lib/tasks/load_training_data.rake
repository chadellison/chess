desc "load_training_data"
task load_training_data: :environment do
  72.times do |count|
    puts 'file: ' + count.to_s
    parse_file(count + 1)
  end
  puts '---------------GAMES LOADED---------------'
end

def parse_file(file_number)
  File.read("#{Rails.root}/training_data/game_set#{file_number}.pgn")
      .gsub(/\[.*?\]/, 'game')
      .split('game')
      .map { |moves| moves.gsub("\r\n", ' ') }
      .reject(&:blank?)
      .map { |moves| make_substitutions(moves) }[1..-1]
      .each { |moves| create_training_game(moves) }
end

def make_substitutions(moves)
  moves.gsub(/[\r\n+]/, '').gsub(/\{.*?\}/, '').gsub('.', '. ').split(' ')
       .reject { |move| move.include?('.') }.join('.')
end

def create_training_game(moves)
  if unique_game?(moves)
    result = moves[-3..-1]
    condensed_moves = moves[0..-4]

    puts "\ngame *****************************************************"
    puts moves[0..-4]

    move_notation = moves[-7..-1] == '1/2-1/2' ? moves[0..-8] : moves[0..-4]

    outcome = find_outcome(result)
    game = Game.create(notation: move_notation, outcome: outcome)

    puts(outcome)
  end
end

def find_outcome(result)
  case result
  when '0-1' then '0'
  when '1-0' then '1'
  else '0.5'
  end
end

def unique_game?(moves)
  Game.find_by(notation: moves[0..-4]).blank?
end
