require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)
require 'clockwork'
require 'open-uri'

SUBJECTS = %w(主人公 友達 先生 館の女主人 メイド 少女 妖精 魔法使い オオカミ 旅人 ダスク バスターブレイド アマリリス ベルベット ファイナルデイ)

module Clockwork
  every(1.hour, 'graph cache') do
     Rails.cache.write("dashboard", Score.dashboard_graphs)
     SUBJECTS.each do |subject|
       Rails.cache.write("index/#{subject}/graph", Score.detail_graph(subject))
     end
  end

end

