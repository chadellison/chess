desc 'delete moves'
task delete_moves: :environment do
  delete_moves
  puts '-------------------THE END-----------------'
end

def delete_moves
  if Move.count.present?
    move_batch = Move.limit(1000)
    move_batch.destroy_all
    puts 'moves destroyed'
    delete_moves
  end
end
