module ApplicationHelper
  # Exibe os pontos de uma celebridade para um ano específico
  # Se a morte não contar para aquele ano, mostra "0 pontos" e a data de morte
  def display_points_for_year(celebrity, year)
    return "-" unless celebrity.is_deceased?
    
    points = celebrity.points_for_year(year)
    counts = celebrity.death_counts_for_year?(year)
    
    if counts && points && points > 0
      content_tag(:span, "#{points} pontos", class: "points")
    elsif celebrity.death_date.present?
      # Morte não conta para este ano - mostra 0 pontos com data
      content_tag(:span, "0 pontos", class: "points") + 
      " (#{celebrity.death_date.strftime("%d/%m/%Y")})"
    else
      content_tag(:span, "0 pontos", class: "points")
    end
  end

  # Retorna o nome do usuário com emojis de vitórias
  def display_user_with_trophies(user)
    wins = user.championship_wins
    return user.username if wins == 0
    "#{user.username} #{'☠️' * wins}"
  end
end
