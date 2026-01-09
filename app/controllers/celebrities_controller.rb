class CelebritiesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_celebrity, only: [:show, :edit, :update, :mark_deceased]

  def index
    @celebrities = Celebrity.order(:name)
  end

  def show
  end

  def new
    @celebrity = Celebrity.new
  end

  def create
    @celebrity = Celebrity.new(celebrity_params)

    if @celebrity.save
      redirect_to celebrities_path, notice: "Celebridade criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @celebrity.update(celebrity_params)
      redirect_to celebrities_path, notice: "Celebridade atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_deceased
  end

  def update_deceased
    @celebrity = Celebrity.find(params[:id])
    
    if @celebrity.update(
      is_deceased: true,
      age_at_death: params[:celebrity][:age_at_death],
      death_date: params[:celebrity][:death_date]
    )
      redirect_to celebrities_path, notice: "Celebridade marcada como morta e pontos calculados!"
    else
      render :mark_deceased, status: :unprocessable_entity
    end
  end

  def merge
    @source_celebrity = Celebrity.find(params[:id])
    @target_celebrity = Celebrity.find(params[:target_id])

    if @source_celebrity.id == @target_celebrity.id
      redirect_to celebrities_path, alert: "Não é possível mesclar uma celebridade com ela mesma!"
      return
    end

    Celebrity.transaction do
      @source_celebrity.player_lists.update_all(celebrity_id: @target_celebrity.id)
      @source_celebrity.destroy
    end

    redirect_to celebrities_path, notice: "Celebridades mescladas com sucesso!"
  end

  private

  def set_celebrity
    @celebrity = Celebrity.find(params[:id])
  end

  def celebrity_params
    params.require(:celebrity).permit(:name, :age_at_death, :death_date, :is_deceased)
  end

  def ensure_admin
    redirect_to root_path, alert: "Acesso negado!" unless current_user&.admin?
  end
end

