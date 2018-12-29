class DashboardController < ApplicationController
  def index
    @graphs = Rails.cache.fetch("dashboard") do
      Score.dashboard_graphs
    end
  end
end
