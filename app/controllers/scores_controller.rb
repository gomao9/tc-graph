class ScoresController < ApplicationController
  before_action :set_subject, only: :index

  def index
    datetimes = Score.where(subject: @subject).order(:datetime).pluck(:datetime).uniq
    datetimes.map! { |d| d.strftime('%m/%d %H:%M') }

    idols = Score.where(subject: @subject, idol: @target_idols).order(:idol, :datetime)
    idols = idols.group_by(&:idol)

    diffs = Score.where(subject: @subject, rank: [1, 2]).order(:datetime, :rank)
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

  def wastes
    mdate = Score.maximum(:datetime)
    sums = Score.where(datetime: mdate).group(:idol).sum(:score)
    maxs = Score.where(datetime: mdate).group(:idol).maximum(:score)
    idols, scores = sums.merge(maxs) {|_k, s, m| s - m }.sort_by(&:last).reverse.transpose

    @graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.title('死票数')
      f.xAxis(categories: idols)
      f.series(type: :column, name: '死票数', data: scores)
    end
  end

  def changes
    results = Score.where(rank: 1).order(:datetime).group_by(&:subject).map do |subject, scores|
      [subject, scores.map(&:idol).chunk(&:itself).count - 1]
    end
    casts, times = results.sort_by(&:last).reverse.transpose


    @graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.title('1位入れ替わり回数')
      f.xAxis(categories: casts)
      f.series(type: :column, name: '1位入れ替わり回数', data: times)
    end
  end

  private

  def set_subject
    @subject = case params[:subject]
               when 'heroine'
                 @subject = '主人公'
               when 'friend'
                 @subject = '友達'
               when 'teacher'
                 @subject = '先生'
               when 'landlady'
                 @subject = '館の女主人'
               when 'maid'
                 @subject = 'メイド'
               when 'girl'
                 @subject = '少女'
               when 'fairy'
                 @subject = '妖精'
               when 'witch'
                 @subject = '魔法使い'
               when 'wolf'
                 @subject = 'オオカミ'
               when 'traveller'
                 @subject = '旅人'
               when 'dusk'
                 @subject = 'ダスク'
               when 'busterblade'
                 @subject = 'バスターブレイド'
               when 'amaryllis'
                 @subject = 'アマリリス'
               when 'velvet'
                 @subject = 'ベルベット'
               when 'finalday'
                 @subject = 'ファイナルデイ'
               else
                 @subject = '主人公'
               end
    newest = Score.where(subject: @subject).order(datetime: :desc).first.datetime
    @target_idols = Score.where(subject: @subject, datetime: newest).order(:rank).limit(3).pluck(:idol)
  end
end
