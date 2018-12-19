require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)
require 'clockwork'
require 'open-uri'


module Clockwork
  every(5.minutes, '5minutely update') do
    casts = JSON.parse open('https://api.matsurihi.me/mltd/v1/election/current').read

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

    Score.transaction do
      scores.each do |s|
       Score.find_or_create_by(s)
      end
    end
  end
end
