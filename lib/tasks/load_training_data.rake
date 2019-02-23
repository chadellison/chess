desc "load_training_data"
task load_training_data: :environment do
  46.times do |count|
    puts 'file: ' + count.to_s
    parse_file(46 + count + 1)
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
  if non_draw?(moves) && unique_game?(moves)
    result = moves[-3..-1]
    condensed_moves = moves[0..-4]

    puts "\ngame *****************************************************"
    puts moves[0..-4]

    oucome = find_outcome(result)
    game = Game.create(notation: moves[0..-4], outcome: oucome)

    puts(oucome)
  end
end

def find_outcome(result)
  result == '0-1' ? -1 : 1
end

def non_draw?(moves)
  ['0-1', '1-0'].include?(moves[-3..-1])
end

def unique_game?(moves)
  Game.find_by(notation: moves[0..-4]).blank?
end
