class PlayerListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_player_list, only: [:destroy]

  def index
    @player_lists = current_user.player_lists.for_year(@current_year).includes(:celebrity).order(:position)
  end

  def show
    @user = User.find(params[:id])
    @player_lists = @user.player_lists.for_year(@current_year).includes(:celebrity).order(:position)
  end

  def create
    if year_locked? && !current_user.admin?
      redirect_to player_lists_path(year: @current_year), alert: "Este ano está bloqueado. Apenas administradores podem editar."
      return
    end

    celebrity = Celebrity.find_or_create_by(name: params[:celebrity_name])
    
    next_position = current_user.player_lists.for_year(@current_year).maximum(:position).to_i + 1
    
    @player_list = current_user.player_lists.build(
      celebrity: celebrity,
      position: next_position,
      year: @current_year
    )

    if @player_list.save
      redirect_to player_lists_path(year: @current_year), notice: "Celebridade adicionada à sua lista!"
    else
      redirect_to player_lists_path(year: @current_year), alert: @player_list.errors.full_messages.join(", ")
    end
  end

  def destroy
    if year_locked? && !current_user.admin?
      redirect_to player_lists_path(year: @current_year), alert: "Este ano está bloqueado. Apenas administradores podem editar."
      return
    end

    @player_list.destroy
    redirect_to player_lists_path(year: @current_year), notice: "Celebridade removida da sua lista!"
  end

  private

  def year_locked?
    @current_game_year&.locked? || false
  end

  private

  def set_player_list
    @player_list = current_user.player_lists.find(params[:id])
  end
end

