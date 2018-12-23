class DashboardController < ApplicationController
  def index
    subject = '主人公'
    idol_count = 3
    newest = Score.where(subject: subject).order(datetime: :desc).first.datetime
    target_idols = Score.where(subject: subject, datetime: newest).order(:rank).limit(idol_count).pluck(:idol)
    pp datetimes = Score.where(subject: subject).order(:datetime).pluck(:datetime).uniq.last(24*60/5)
    pp start_date = datetimes.first
    datetimes.map! { |d| d.strftime('%m/%d %H:%M') }


    datetime_condition = Score.arel_table[:datetime].gteq(start_date)
    idols = Score.where(subject: subject, idol: target_idols).where(datetime_condition).order(:idol, :datetime)
    idols = idols.group_by(&:idol)

    diffs = Score.where(subject: subject, rank: [1, 2]).where(datetime_condition).order(:datetime, :rank)
    diffs = diffs.group_by(&:datetime).map { |_group, (first, second)| first.score - second.score }

    @graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.title('得票数推移')
      f.xAxis(categories: datetimes)
      f.yAxis([
        { title: { text: '総得票数' } },
        { title: { text: '票差' }, gridLineWidth: 0, opposite: true },
      ])

      f.chart(zoomType: 'x',
              panning: true,
              panKey: 'shift',
              resetZoomButton: { position: { align: 'center' } },
             )

      idols.each do |idol, scores|
        f.series(name: idol, data: scores.map(&:score), marker: { enabled: false })
      end

      f.series(name: '1位と2位の差', data: diffs, marker: { enabled: false }, yAxis: 1)
    end
  end
end
