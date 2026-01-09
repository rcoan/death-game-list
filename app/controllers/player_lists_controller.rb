class PlayerListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_player_list, only: [:destroy]

  def index
    @player_lists = current_user.player_lists.includes(:celebrity).order(:position)
  end

  def show
    @user = User.find(params[:id])
    @player_lists = @user.player_lists.includes(:celebrity).order(:position)
  end

  def create
    celebrity = Celebrity.find_or_create_by(name: params[:celebrity_name])
    
    next_position = current_user.player_lists.maximum(:position).to_i + 1
    
    @player_list = current_user.player_lists.build(
      celebrity: celebrity,
      position: next_position
    )

    if @player_list.save
      redirect_to player_lists_path, notice: "Celebridade adicionada à sua lista!"
    else
      redirect_to player_lists_path, alert: @player_list.errors.full_messages.join(", ")
    end
  end

  def destroy
    @player_list.destroy
    redirect_to player_lists_path, notice: "Celebridade removida da sua lista!"
  end

  private

  def set_player_list
    @player_list = current_user.player_lists.find(params[:id])
  end
end

