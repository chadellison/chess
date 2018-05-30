desc 'Train AI'
task train_ai: :environment do
  game_scope.find_each do |game|
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

def game_scope
  game_count = ENV['GAME_COUNT']
  offset = ENV['OFFSET']

  if game_count.present? && offset.present?
    Game.where(outcome: [1, -1]).limit(game_count.to_i).offset(offset.to_i)
  else
    Game.where(outcome: [1, -1])
  end
end
