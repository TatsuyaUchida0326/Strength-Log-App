class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]

  def index
    @users = User.all
  end

  def show
    month_exercises = Exercise.where(date: @start_date..@end_date)
    @user = User.find(params[:id])
    @date = params[:month] ? Date.parse(params[:month]) : Date.today
    # 月の開始日と終了日を取得
    @start_date = @date.beginning_of_month.beginning_of_week(:sunday)
    @end_date = @date.end_of_month.end_of_week(:sunday)
    @training_days = month_exercises.group_by { |e| e.date.to_date }.transform_values(&:count)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end

    # ログイン済みのユーザーか確認します。
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end
end