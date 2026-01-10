class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_current_year
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  def set_current_year
    if params[:year].present?
      year = params[:year].to_i
      # Validar se o ano existe e está ativo
      if GameYear.active.exists?(year: year)
        session[:selected_year] = year
      end
    end
    
    # Se não tem ano na sessão, usar o ano mais recente ativo (2026 por padrão)
    if session[:selected_year].nil?
      default_year = GameYear.active.ordered.first&.year || 2026
      session[:selected_year] = default_year
    end
    
    @current_year = session[:selected_year] || 2026
    @current_game_year = GameYear.find_by(year: @current_year)
    @available_years = GameYear.active.ordered.pluck(:year)
  end
end
