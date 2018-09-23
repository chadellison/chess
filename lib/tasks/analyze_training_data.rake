desc 'Train AI'
task analyze_training_data: :environment do
  analyzed_games = []
  game_scope.find_each do |game|
    puts 'Game ' + game.id.to_s
    analyzed_game = Concurrent::Future.execute do
      game.notation.split('.').each_with_index do |move_notation, index|
        turn = index.even? ? 'white' : 'black'
        game.update_game_from_notation(move_notation.sub('#', ''), turn)
        game.reload_pieces
        puts 'Setup ' + game.moves.last.setup.position_signature
      end
      game.propogate_results
    end
    analyzed_games << analyzed_game
  end


  analyzed_games.each do |ag|
    if ag.rejected?
      puts 'WE BLEW UP!!!'
    end
    ag.value
  end
  puts '---------------THE END---------------'
end

def game_scope
  game_count = ENV['GAME_COUNT']
  offset = ENV['OFFSET']

  if game_count.present? && offset.present?
    Game.where(outcome: [1, -1]).limit(game_count.to_i).offset(offset.to_i)
  else
    Game.where(outcome: [1, -1])
  end
end
