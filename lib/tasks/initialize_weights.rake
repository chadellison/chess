desc 'initialize weights'
  task initialize_weights: :environment do
  Weight.initialize_weights
  puts 'created weights'
  puts '__________________________THE END__________________________'
end
