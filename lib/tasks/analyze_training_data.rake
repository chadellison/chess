desc 'Train AI'
task analyze_training_data: :environment do
  analyze_game
  puts '---------------THE END---------------'
end

def analyze_game
  game = Game.find_by(analyzed: false)
  if game.present?
    game.update(analyzed: true)
    puts 'Game ' + game.id.to_s
    game.notation.split('.').each_with_index do |move_notation, index|
      turn = index.even? ? 'white' : 'black'
      game.update_game_from_notation(move_notation.sub('#', ''), turn)
      game.reload_pieces
      puts 'Setup ' + game.moves.last.setup.position_signature
    end
    game.propogate_results
    analyze_game
  end
end
