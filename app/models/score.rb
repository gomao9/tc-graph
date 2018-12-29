class Score < ApplicationRecord
  def self.detail_graph(subject)
    graph(subject, datetimes(subject))
  end

  def self.dashboard_graphs
    {
      heroine:     Score.dashboard_graph('主人公'),
      friend:      Score.dashboard_graph('友達'),
      teacher:     Score.dashboard_graph('先生'),
      landlady:    Score.dashboard_graph('館の女主人'),
      maid:        Score.dashboard_graph('メイド'),

      girl:        Score.dashboard_graph('少女'),
      fairy:       Score.dashboard_graph('妖精'),
      witch:       Score.dashboard_graph('魔法使い'),
      wolf:        Score.dashboard_graph('オオカミ'),
      traveller:   Score.dashboard_graph('旅人'),

      dusk:        Score.dashboard_graph('ダスク'),
      busterblade: Score.dashboard_graph('バスターブレイド'),
      amaryllis:   Score.dashboard_graph('アマリリス'),
      velvet:      Score.dashboard_graph('ベルベット'),
      finalday:    Score.dashboard_graph('ファイナルデイ'),
    }
  end

  private

  def self.dashboard_graph(subject)
    graph(subject, datetimes_in24h(subject))
  end


  def self.graph(subject, datetimes)
    datetime_condition = Score.arel_table[:datetime].gteq(datetimes.first)

    idol_count = 3
    target_idols = Score.where(subject: subject, datetime: datetimes.last).order(:rank).limit(idol_count).pluck(:idol)
    idols = Score.where(subject: subject, idol: target_idols).where(datetime_condition).order(:idol, :datetime)
    idols = idols.group_by(&:idol)

    diffs = Score.where(subject: subject, rank: [1, 2]).where(datetime_condition).order(:datetime, :rank)
    diffs = diffs.group_by(&:datetime).map { |_group, (first, second)| first.score - second.score }

    LazyHighCharts::HighChart.new(subject) do |f|
      f.title('得票数推移')
      f.xAxis(categories: formatted_datetimes(subject))
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

  scope :datetimes, -> (subject) { where(subject: subject).order(:datetime).pluck(:datetime).uniq }
  scope :datetimes_in24h, -> (subject) { datetimes(subject).last(24*60/5) }
  scope :formatted_datetimes, -> (subject) { datetimes(subject).map { |d| d.strftime('%m/%d %H:%M') } }

  scope :diffs, -> (subject) do
    diffs = where(subject: subject, rank: [1, 2]).order(:datetime, :rank)
    diffs.group_by(&:datetime).map { |_group, (first, second)| first.score - second.score }
  end
end
