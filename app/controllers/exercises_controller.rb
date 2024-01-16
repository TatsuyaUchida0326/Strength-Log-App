  class ExercisesController < ApplicationController
    before_action :set_exercise, only: [:edit, :update, :destroy]
    
    def new
      @exercise = Exercise.new
      @exercise.date = params[:date] if params[:date].present?
    end
  
    def create
      if params[:exercise_id]
        # 既存のトレーニング種目を複製して新しい日付で保存
        original_exercise = Exercise.find(params[:exercise_id])
        @exercise = original_exercise.dup
        @exercise.date = params[:date]
      else
        # 新しいトレーニング種目を作成
        @exercise = Exercise.new(exercise_params)
      end
    
      if @exercise.save
        redirect_to exercises_path(date: @exercise.date.strftime("%Y-%m-%d")), notice: 'トレーニングが追加されました。'
      else
        render :new
      end
    end

    def destroy
      @exercise = Exercise.find(params[:id])
      date_of_exercise = @exercise.date.strftime("%Y-%m-%d") # トレーニングの日付を取得
      @exercise.destroy
      redirect_to exercises_path(date: date_of_exercise), notice: 'エクササイズが削除されました。'
    end

    def index
      if params[:date]
        @selected_date = params[:date].to_date
        @exercises = Exercise.where(date: @selected_date)
      else
        @exercises = Exercise.all
      end
    end
    
    def strength_log
      @exercises = Exercise.order(:part)
    end
    
    def edit
      @exercise = Exercise.find(params[:id])
    end
    
    def update
      @exercise = Exercise.find(params[:id])
      if @exercise.update(exercise_params)
        date_of_exercise = @exercise.date.strftime("%Y-%m-%d") # トレーニングの日付を取得
        redirect_to exercises_path(date: date_of_exercise), notice: '種目が更新されました。'
      else
        render :edit
      end
    end

    private
    
    def set_exercise
      @exercise = Exercise.find(params[:id])
    end
    # Strong Parametersを使用して安全にパラメータを取り扱う
    def exercise_params
      params.require(:exercise).permit(:part, :exercise, :date) # 'date' を追加
    end
  end