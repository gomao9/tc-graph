class DashboardController < ApplicationController
  def index
    @graphs = Rails.cache.fetch("dashboard", expired_in: 10.minutes) do
      subject = '主人公'
      newest = Score.where(subject: subject).order(datetime: :desc).first.datetime
      datetimes = Score.where(subject: subject).order(:datetime).pluck(:datetime).uniq.last(24*60/5)
      start_date = datetimes.first
      datetimes.map! { |d| d.strftime('%m/%d %H:%M') }
      datetime_condition = Score.arel_table[:datetime].gteq(start_date)

      {
        heroine: graph('主人公', datetimes, newest, datetime_condition),
        friend: graph('友達', datetimes, newest, datetime_condition),
        teacher: graph('先生', datetimes, newest, datetime_condition),
        landlady: graph('館の女主人', datetimes, newest, datetime_condition),
        maid: graph('メイド', datetimes, newest, datetime_condition),

        girl: graph('少女', datetimes, newest, datetime_condition),
        fairy: graph('妖精', datetimes, newest, datetime_condition),
        witch: graph('魔法使い', datetimes, newest, datetime_condition),
        wolf: graph('オオカミ', datetimes, newest, datetime_condition),
        traveller: graph('旅人', datetimes, newest, datetime_condition),

        dusk: graph('ダスク', datetimes, newest, datetime_condition),
        busterblade: graph('バスターブレイド', datetimes, newest, datetime_condition),
        amaryllis: graph('アマリリス', datetimes, newest, datetime_condition),
        velvet: graph('ベルベット', datetimes, newest, datetime_condition),
        finalday: graph('ファイナルデイ', datetimes, newest, datetime_condition),
      }
    end
  end

  private

  def graph(subject, datetimes, newest, datetime_condition)
    idol_count = 3
    target_idols = Score.where(subject: subject, datetime: newest).order(:rank).limit(idol_count).pluck(:idol)
    idols = Score.where(subject: subject, idol: target_idols).where(datetime_condition).order(:idol, :datetime)
    idols = idols.group_by(&:idol)

    diffs = Score.where(subject: subject, rank: [1, 2]).where(datetime_condition).order(:datetime, :rank)
    diffs = diffs.group_by(&:datetime).map { |_group, (first, second)| first.score - second.score }

    LazyHighCharts::HighChart.new(subject) do |f|
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
