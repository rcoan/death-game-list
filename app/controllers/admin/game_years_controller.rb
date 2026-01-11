class Admin::GameYearsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_game_year, only: [:show, :edit, :update, :destroy]

  def index
    @game_years = GameYear.ordered
  end

  def show
  end

  def new
    @game_year = GameYear.new
  end

  def create
    @game_year = GameYear.new(game_year_params)

    if @game_year.save
      redirect_to admin_game_years_path, notice: "Ano criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @game_year.update(game_year_params)
      redirect_to admin_game_years_path, notice: "Ano atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game_year.destroy
    redirect_to admin_game_years_path, notice: "Ano deletado com sucesso!"
  end

  private

  def set_game_year
    @game_year = GameYear.find(params[:id])
  end

  def game_year_params
    params.require(:game_year).permit(:year, :is_active, :locked, :start_date)
  end

  def ensure_admin
    redirect_to root_path, alert: "Acesso negado!" unless current_user&.admin?
  end
end

