desc 'Train AI'
task train_ai: :environment do
  Game.where.not(outcome: 0).find_each do |game|
    puts 'Game ' + game.id.to_s
    game.notation.split('.').each_with_index do |move_notation, index|
      turn = index.even? ? 'white' : 'black'
      game.create_move_from_notation(move_notation.sub('#', ''), turn)
      game.reload.update_board
      puts 'Setup ' + game.setups.last.position_signature
    end
    game.setups.each do |setup|
      setup.update(rank: (setup.rank + game.outcome))
    end
  end
end
