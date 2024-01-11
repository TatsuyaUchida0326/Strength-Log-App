  class ExercisesController < ApplicationController
    before_action :set_exercise, only: [:edit, :update, :destroy]
    
    def new
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
      @exercises = Exercise.order(:part)
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
      params.require(:exercise).permit(:part, :exercise, :name) # 'name' を追加
    end
  end