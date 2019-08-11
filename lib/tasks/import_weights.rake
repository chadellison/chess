desc 'import weights'
task import_weights: :environment do
  Weight.destroy_all
  json_weights = JSON.parse(File.read(Rails.root + 'json/weights.json'))
                    .map(&:symbolize_keys)

  json_weights.each do |json_weight|
    Weight.create(json_weight)
  end
  puts 'updated weights from json/weights.json'
end
