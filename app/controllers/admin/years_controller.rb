class Admin::YearsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_year, only: [:show, :edit, :update, :destroy]

  def index
    @years = Year.ordered
  end

  def show
  end

  def new
    @year = Year.new
  end

  def create
    @year = Year.new(year_params)

    if @year.save
      redirect_to admin_years_path, notice: "Ano criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @year.update(year_params)
      redirect_to admin_years_path, notice: "Ano atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @year.destroy
    redirect_to admin_years_path, notice: "Ano deletado com sucesso!"
  end

  private

  def set_year
    @year = Year.find(params[:id])
  end

  def year_params
    params.require(:year).permit(:value, :is_active)
  end

  def ensure_admin
    redirect_to root_path, alert: "Acesso negado!" unless current_user&.admin?
  end
end

