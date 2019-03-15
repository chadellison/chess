desc 'delete games'
task delete_games: :environment do
  delete_games
  puts '-------------------THE END-------------------'
end

def delete_games
  analyzed_games = Game.where(analyzed: true).limit(100)
  if analyzed_games.present?
    analyzed_games.destroy_all
    puts 'games destroyed'
    delete_games
  end
end
