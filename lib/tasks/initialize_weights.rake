desc 'initialize weights'
  task initialize_weights: :environment do
  Weight.initialize_weights
  puts 'creating weights'
  puts '__________________________THE END__________________________'
end
