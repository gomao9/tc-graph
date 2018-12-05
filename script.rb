require 'json'
require 'ostruct'

snapshots = JSON.load(open('/Users/hsugita/Downloads/tb_included.json').read)
records = snapshots.flat_map do |snapshot|
  datetime = snapshot.delete('datetime')
  snapshot.flat_map do |cast, ranks|
    ranks.map do |_rank, data|
      OpenStruct.new(
        datetime: Time.new(datetime),
        cast: cast,
        idol: data['idol'],
        score: data['score'],
      )
    end
  end
end

require 'pp'
groups = records.select { |r| r.cast == 'ネコ' }.group_by do |r|
  [r.datetime, r.idol]
end
pp groups
