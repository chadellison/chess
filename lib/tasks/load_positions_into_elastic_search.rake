desc 'load_positions_into_elastic_search'
task load_positions_into_elastic_search: :environment do
  positions = REDIS.hscan_each('positions').map do |position_data|
    JSON.parse(position_data.last)
  end
  PositionIndex.import(positions)
end
