class DashboardController < ApplicationController
  def index
    # Apenas usuários que têm lista no ano selecionado
    user_ids_with_lists = PlayerList.for_year(@current_year).distinct.pluck(:user_id)
    users_with_lists = User.where(id: user_ids_with_lists)
    
    @current_game_year = GameYear.find_by(year: @current_year)
    @year_start_date = @current_game_year&.start_date || Date.new(@current_year, 1, 15)
    @year_end_date = Date.new(@current_year + 1, 1, 1)
    
    @users = users_with_lists.map do |user|
      { user: user, total_points: user.total_points(@current_year) }
    end.sort_by { |u| -u[:total_points] }

    # Todas as mortes de celebridades que estão nas listas do ano selecionado
    # Apenas mortes que ocorreram após a start_date do ano
    celebrity_ids_in_lists = PlayerList.for_year(@current_year).pluck(:celebrity_id).uniq
    @all_deaths = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                          .where("death_date >= ? AND death_date < ?", @year_start_date, @year_end_date)
                          .order(death_date: :desc)

    deaths_in_lists = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                              .where.not(death_date: nil)
                              .where("death_date >= ? AND death_date < ?", @year_start_date, @year_end_date)
    
    # Criar dados cumulativos para todos os 12 meses do ano em ordem cronológica
    year = @current_year
    months_order = (1..12).map { |m| Date.new(year, m, 1).strftime("%b %Y") }
    
    # Contar mortes por mês
    deaths_by_month_raw = deaths_in_lists.group_by { |c| c.death_date&.strftime("%b %Y") }
                                         .transform_values(&:count)
    
    # Criar dados cumulativos ordenados
    cumulative = 0
    @deaths_by_month = {}
    months_order.each do |month|
      cumulative += deaths_by_month_raw[month].to_i
      @deaths_by_month[month] = cumulative
    end
    
    # Dados para gráfico de distribuição de pontos
    @points_distribution = {
      "0-20" => users_with_lists.count { |u| (0..20).include?(u.total_points(@current_year)) },
      "21-40" => users_with_lists.count { |u| (21..40).include?(u.total_points(@current_year)) },
      "41-60" => users_with_lists.count { |u| (41..60).include?(u.total_points(@current_year)) },
      "61-80" => users_with_lists.count { |u| (61..80).include?(u.total_points(@current_year)) },
      "81+" => users_with_lists.count { |u| u.total_points(@current_year) > 80 }
    }
    
    # Celebridades mais mortais (mais pontos distribuídos)
    @deadliest_celebrities = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                                      .joins(:player_lists)
                                      .where(player_lists: { year: @current_year })
                                      .group('celebrities.id', 'celebrities.name', 'celebrities.points')
                                      .select('celebrities.id, celebrities.name, celebrities.points, COUNT(player_lists.id) as list_count')
                                      .order('celebrities.points DESC')
                                      .limit(10)
                                      .map { |c| { name: c.name, points: c.points, count: c.list_count } }
    
    # Dados para gráfico de pontos vs popularidade (quantas listas têm cada celebridade)
    @points_vs_popularity = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                                     .where.not(points: nil)
                                     .joins(:player_lists)
                                     .where(player_lists: { year: @current_year })
                                     .group('celebrities.id', 'celebrities.name', 'celebrities.points')
                                     .select('celebrities.id, celebrities.name, celebrities.points, COUNT(player_lists.id) as list_count')
                                     .map { |c| { x: c.points, y: c.list_count, label: c.name } }
    
    # Distribuição de idades das mortes
    @age_distribution = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                                 .where.not(age_at_death: nil)
                                 .pluck(:age_at_death)
                                 .group_by { |age| 
                                   case age
                                   when 0..50 then "0-50"
                                   when 51..60 then "51-60"
                                   when 61..70 then "61-70"
                                   when 71..80 then "71-80"
                                   when 81..90 then "81-90"
                                   else "91+"
                                   end
                                 }
                                 .transform_values(&:count)
  end
end

