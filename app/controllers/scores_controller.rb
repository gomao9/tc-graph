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
      f.title('ネコ')
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
               when 'shinnyusei'
                 @subject = '新入生'
               when 'senpai'
                 @subject = '先輩'
               when 'king'
                 @subject = 'キング'
               when 'migiude'
                 @subject = '右腕クイーン'
               when 'doukyusei'
                 @subject = '同級生'
               when 'choujo'
                 @subject = '長女'
               when 'jijo'
                 @subject = '次女'
               when 'sanjo'
                 @subject = '三女'
               when 'cat'
                 @subject = 'ネコ'
               when 'okyakusan'
                 @subject = 'お客さん'
               when 'heroine'
                 @subject = '新ヒロイン'
               when 'star'
                 @subject = 'スタア'
               when 'daijoyu'
                 @subject = '元大女優'
               when 'shihainin'
                 @subject = '支配人'
               when 'tantei'
                 @subject = '探偵'
               else
                 @subject = 'ネコ'
               end
    newest = Score.where(subject: @subject).order(datetime: :desc).first.datetime
    @target_idols = Score.where(subject: @subject, datetime: newest).order(:rank).limit(3).pluck(:idol)
  end
end
