desc 'Train AI'
task train_ai: :environment do
  Game.where.not(outcome: 0).find_each do |game|
    puts 'Game ' + game.id.to_s
    game.notation.split('.').each_with_index do |move_notation, index|
      turn = index.even? ? 'white' : 'black'
      game.update_game_from_notation(move_notation.sub('#', ''), turn)
      puts 'Setup ' + game.moves.last.setup.position_signature
    end
    game.moves.each do |move|
      move.setup.update(rank: (move.setup.rank + game.outcome))
    end
  end
  puts '---------------THE END---------------'
end
