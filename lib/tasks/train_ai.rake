desc 'Train AI'
task train_ai: :environment do
  Game.where.not(outcome: 0).find_each do |game|
    game.notation.split('.').each do |move|
      # update piece position from the move / notation
      game.update_board
      game.setups.last.update(rank: game.outcome)
    end
  end
end
