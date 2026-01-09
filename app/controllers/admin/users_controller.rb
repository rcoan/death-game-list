class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy, :manage_list]

  def index
    @users = User.order(:email)
  end

  def show
    @player_lists = @user.player_lists.for_year(@current_year).includes(:celebrity).order(:position)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = params[:user][:password] if params[:user][:password].present?

    if @user.save
      redirect_to admin_user_path(@user), notice: "Usuário criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:user][:password].present?
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "Usuário atualizado com sucesso!"
      else
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.update(user_params.except(:password))
        redirect_to admin_user_path(@user), notice: "Usuário atualizado com sucesso!"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "Usuário deletado com sucesso!"
  end

  def manage_list
    @player_lists = @user.player_lists.for_year(@current_year).includes(:celebrity).order(:position)
  end

  def add_celebrity_to_list
    @user = User.find(params[:id])
    celebrity = Celebrity.find_or_create_by(name: params[:celebrity_name])
    
    next_position = @user.player_lists.for_year(@current_year).maximum(:position).to_i + 1
    
    @player_list = @user.player_lists.build(
      celebrity: celebrity,
      position: next_position,
      year: @current_year
    )

    if @player_list.save
      redirect_to manage_list_admin_user_path(@user), notice: "Celebridade adicionada à lista!"
    else
      redirect_to manage_list_admin_user_path(@user), alert: @player_list.errors.full_messages.join(", ")
    end
  end

  def remove_from_list
    @user = User.find(params[:id])
    @player_list = @user.player_lists.find(params[:player_list_id])
    @player_list.destroy
    redirect_to manage_list_admin_user_path(@user), notice: "Celebridade removida da lista!"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin)
  end

  def ensure_admin
    redirect_to root_path, alert: "Acesso negado!" unless current_user&.admin?
  end
end

