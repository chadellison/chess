desc 'Train AI'
task analyze_training_data: :environment do
  do_the_thing
  puts '---------------THE END---------------'
end

def do_the_thing
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
    do_the_thing
  end
end
