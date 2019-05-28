desc 'export weights'
task export_weights: :environment do
  weights = Weight.order(:weight_count)
  File.open("#{Rails.root}/json/weights.json","w") do |f|
    f.write(weights.to_json)
  end
  puts 'weights exported to json/weights.json'
end
