  class ExercisesController < ApplicationController
    before_action :set_exercise, only: [:edit, :update, :destroy]
    
    def new
      @exercise = Exercise.new
      @exercise.date = params[:date] if params[:date].present?
    end
  
    def create
      @exercise = Exercise.new(exercise_params)
      if @exercise.save
        redirect_to exercises_path
      else
        render :new
      end
    end
    
    def destroy
      @exercise = Exercise.find(params[:id])
      @exercise.destroy
      redirect_to exercises_path, notice: 'エクササイズが削除されました。'
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
        redirect_to exercises_path, notice: '種目が更新されました。'
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