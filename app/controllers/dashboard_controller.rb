class DashboardController < ApplicationController
  def index
    @users = User.all.map do |user|
      { user: user, total_points: user.total_points }
    end.sort_by { |u| -u[:total_points] }

    @recent_deaths = Celebrity.where(is_deceased: true)
                              .order(death_date: :desc)
                              .limit(10)

    @deaths_by_month = Celebrity.where(is_deceased: true)
                                .where.not(death_date: nil)
                                .group_by { |c| c.death_date&.strftime("%b %Y") }
                                .transform_values(&:count)
  end
end

