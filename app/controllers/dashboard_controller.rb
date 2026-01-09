class DashboardController < ApplicationController
  def index
    # Apenas usuários que têm lista no ano selecionado
    user_ids_with_lists = PlayerList.for_year(@current_year).distinct.pluck(:user_id)
    users_with_lists = User.where(id: user_ids_with_lists)
    
    @users = users_with_lists.map do |user|
      { user: user, total_points: user.total_points(@current_year) }
    end.sort_by { |u| -u[:total_points] }

    # Todas as mortes de celebridades que estão nas listas do ano selecionado
    celebrity_ids_in_lists = PlayerList.for_year(@current_year).pluck(:celebrity_id).uniq
    @all_deaths = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                          .order(death_date: :desc)

    deaths_in_lists = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                              .where.not(death_date: nil)
    
    @deaths_by_month = deaths_in_lists.group_by { |c| c.death_date&.strftime("%b %Y") }
                                      .transform_values(&:count)
  end
end

