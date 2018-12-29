class ScoresController < ApplicationController
  before_action :set_subject, only: :index

  def index
    @newest = Score.where(subject: @subject).order(datetime: :desc).first.datetime
    @ranking = Score.where(subject: @subject, datetime: @newest).order(:rank)
    
    @graph = Rails.cache.fetch("index/#{@subject}/graph") do
      Score.detail_graph(@subject, @newest)
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
  end
end
