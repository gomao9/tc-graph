class Score < ApplicationRecord
  def self.detail_graph(subject, newest)
    datetimes = Score.where(subject: subject).order(:datetime).pluck(:datetime).uniq
    datetimes.map! { |d| d.strftime('%m/%d %H:%M') }

    target_idols = Score.where(subject: subject, datetime: newest).order(:rank).limit(3).pluck(:idol)
    idols = Score.where(subject: subject, idol: target_idols).order(:idol, :datetime)
    idols = idols.group_by(&:idol)

    diffs = Score.where(subject: subject, rank: [1, 2]).order(:datetime, :rank)
    diffs = diffs.group_by(&:datetime).map { |_group, (first, second)| first.score - second.score }

    LazyHighCharts::HighChart.new('graph') do |f|
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
