require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)
require 'clockwork'
require 'open-uri'

SUBJECTS = %w(主人公 友達 先生 館の女主人 メイド 少女 妖精 魔法使い オオカミ 旅人 ダスク バスターブレイド アマリリス ベルベット ファイナルデイ)

module Clockwork
  every(1.minute, 'minutely update') do
    casts = JSON.parse open('https://api.matsurihi.me/mltd/v1/election/current?prettyPrint=false').read

    datetime = nil
    scores = casts.flat_map do |cast|
      subject = cast['name']
      datetime = DateTime.parse(cast['summaryTime'])
      cast['data'].first.map do |idol_rank|
        idol_rank['idol'] = idol_rank.delete('idol_name')
        idol_rank['datetime'] = datetime
        idol_rank['subject'] = subject

        idol_rank.delete('idol_id')

        idol_rank
      end
    end

    unless Score.exists?(datetime: datetime)
      Score.transaction do
        scores.each do |s|
          Score.find_or_create_by(s)
        end
      end
    end
  end

  every(5.minute, 'graph cache') do
     Rails.cache.write("dashboard", Score.dashboard_graphs)
     SUBJECTS.each do |subject|
       Rails.cache.write("index/#{subject}/graph", Score.detail_graph(subject))
     end
  end

end

