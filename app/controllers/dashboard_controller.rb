class DashboardController < ApplicationController
  def rules
  end

  def home
    # Dashboard inicial com visão geral
    @all_years = GameYear.active.ordered
    
    # Rankings rápidos por ano
    @year_rankings = @all_years.map do |game_year|
      year = game_year.year
      user_ids_with_lists = PlayerList.for_year(year).distinct.pluck(:user_id)
      users_with_lists = User.where(id: user_ids_with_lists)
      
      rankings = users_with_lists.map do |user|
        { user: user, total_points: user.total_points(year) }
      end.sort_by { |u| -u[:total_points] }
      
      champion = User.champion_of_year(year)
      
      {
        year: year,
        rankings: rankings,
        champion: champion,
        champion_points: champion ? champion.total_points(year) : 0
      }
    end
    
    # Ranking de campeões
    @champions_ranking = User.champions_ranking
    
    # Relatórios cruzados
    @most_repeated_celebrities = most_repeated_celebrities
    @repetition_vs_death = repetition_vs_death_stats
    @death_statistics = death_statistics
  end

  def index
    # Pegar ano da rota ou usar o padrão
    year = params[:year] ? params[:year].to_i : @current_year
    @view_year = year
    
    # Apenas usuários que têm lista no ano selecionado
    user_ids_with_lists = PlayerList.for_year(@view_year).distinct.pluck(:user_id)
    users_with_lists = User.where(id: user_ids_with_lists)
    
    @current_game_year = GameYear.find_by(year: @view_year)
    @year_start_date = @current_game_year&.start_date || Date.new(@view_year, 1, 15)
    @year_end_date = Date.new(@view_year + 1, 1, 1)
    
    @users = users_with_lists.map do |user|
      { user: user, total_points: user.total_points(@view_year) }
    end.sort_by { |u| -u[:total_points] }
    
    # Todas as mortes de celebridades que estão nas listas do ano selecionado
    # Apenas mortes que ocorreram após a start_date do ano
    celebrity_ids_in_lists = PlayerList.for_year(@view_year).pluck(:celebrity_id).uniq
    @all_deaths = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                          .where("death_date >= ? AND death_date < ?", @year_start_date, @year_end_date)
                          .order(death_date: :desc)
    
    deaths_in_lists = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                              .where.not(death_date: nil)
                              .where("death_date >= ? AND death_date < ?", @year_start_date, @year_end_date)
    
    # Criar dados cumulativos para todos os 12 meses do ano em ordem cronológica
    year = @view_year
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
      "0-20" => users_with_lists.count { |u| (0..20).include?(u.total_points(@view_year)) },
      "21-40" => users_with_lists.count { |u| (21..40).include?(u.total_points(@view_year)) },
      "41-60" => users_with_lists.count { |u| (41..60).include?(u.total_points(@view_year)) },
      "61-80" => users_with_lists.count { |u| (61..80).include?(u.total_points(@view_year)) },
      "81+" => users_with_lists.count { |u| u.total_points(@view_year) > 80 }
    }
    
    # Celebridades mais mortais (mais pontos distribuídos)
    @deadliest_celebrities = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                                      .joins(:player_lists)
                                      .where(player_lists: { year: @view_year })
                                      .group('celebrities.id', 'celebrities.name', 'celebrities.points')
                                      .select('celebrities.id, celebrities.name, celebrities.points, COUNT(player_lists.id) as list_count')
                                      .order('celebrities.points DESC')
                                      .limit(10)
                                      .map { |c| { name: c.name, points: c.points, count: c.list_count } }
    
    # Dados para gráfico de pontos vs popularidade (quantas listas têm cada celebridade)
    @points_vs_popularity = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                                     .where.not(points: nil)
                                     .joins(:player_lists)
                                     .where(player_lists: { year: @view_year })
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

  private

  # Celebridades que mais apareceram em listas (repetição)
  def most_repeated_celebrities
    all_years = GameYear.active.ordered.pluck(:year)
    
    celebrity_appearances = {}
    
    all_years.each do |year|
      PlayerList.for_year(year).includes(:celebrity).each do |player_list|
        name = player_list.celebrity.name
        celebrity_appearances[name] ||= { count: 0, years: [], is_deceased: player_list.celebrity.is_deceased? }
        celebrity_appearances[name][:count] += 1
        celebrity_appearances[name][:years] << year unless celebrity_appearances[name][:years].include?(year)
      end
    end
    
    celebrity_appearances.to_a
                        .sort_by { |_, data| -data[:count] }
                        .first(20)
                        .map { |name, data| { name: name, appearances: data[:count], years_count: data[:years].count, is_deceased: data[:is_deceased] } }
  end

  # Estatísticas de repetição vs morte
  def repetition_vs_death_stats
    all_years = GameYear.active.ordered.pluck(:year)
    
    stats = {
      repeated_and_died: 0,
      repeated_but_alive: 0,
      appeared_once_and_died: 0,
      appeared_once_and_alive: 0
    }
    
    celebrity_data = {}
    
    all_years.each do |year|
      PlayerList.for_year(year).includes(:celebrity).each do |player_list|
        name = player_list.celebrity.name
        celebrity_data[name] ||= { appearances: 0, is_deceased: player_list.celebrity.is_deceased? }
        celebrity_data[name][:appearances] += 1
      end
    end
    
    celebrity_data.each do |name, data|
      if data[:appearances] > 1
        if data[:is_deceased]
          stats[:repeated_and_died] += 1
        else
          stats[:repeated_but_alive] += 1
        end
      else
        if data[:is_deceased]
          stats[:appeared_once_and_died] += 1
        else
          stats[:appeared_once_and_alive] += 1
        end
      end
    end
    
    stats
  end

  # Estatísticas de mortes: quantidade vs pontuação vs chance de ganhar
  def death_statistics
    all_years = GameYear.active.ordered.pluck(:year)
    
    stats_by_year = all_years.map do |year|
      game_year = GameYear.find_by(year: year)
      next nil unless game_year
      
      user_ids_with_lists = PlayerList.for_year(year).distinct.pluck(:user_id)
      users_with_lists = User.where(id: user_ids_with_lists)
      
      # Mortes do ano
      celebrity_ids_in_lists = PlayerList.for_year(year).pluck(:celebrity_id).uniq
      deaths = Celebrity.where(id: celebrity_ids_in_lists, is_deceased: true)
                       .where("death_date >= ? AND death_date < ?", game_year.start_date, Date.new(year + 1, 1, 1))
      
      total_deaths = deaths.count
      total_points = deaths.sum(:points) || 0
      avg_points = total_deaths > 0 ? (total_points.to_f / total_deaths).round(2) : 0
      max_points = deaths.maximum(:points) || 0
      
      # Pontuação do campeão
      champion = User.champion_of_year(year)
      champion_points = champion ? champion.total_points(year) : 0
      
      # Chance de ganhar (pontos do campeão / total de pontos possíveis)
      # Assumindo que cada jogador tem 20 celebridades, máximo teórico seria 20 * 100 = 2000
      # Mas vamos usar o máximo real de pontos distribuídos
      max_possible_points = deaths.sum { |d| d.points || 0 } * users_with_lists.count
      win_probability = max_possible_points > 0 ? ((champion_points.to_f / max_possible_points) * 100).round(2) : 0
      
      {
        year: year,
        total_deaths: total_deaths,
        total_points: total_points,
        avg_points: avg_points,
        max_points: max_points,
        champion_points: champion_points,
        win_probability: win_probability
      }
    end.compact
    
    {
      by_year: stats_by_year,
      overall: {
        total_deaths: stats_by_year.sum { |s| s[:total_deaths] },
        avg_deaths_per_year: (stats_by_year.sum { |s| s[:total_deaths] }.to_f / stats_by_year.count).round(2),
        avg_points_per_death: (stats_by_year.sum { |s| s[:avg_points] }.to_f / stats_by_year.count).round(2)
      }
    }
  end
end

