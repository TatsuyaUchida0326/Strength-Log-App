class ExercisesController < ApplicationController
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
  
  private
  # Strong Parametersを使用して安全にパラメータを取り扱う
  def exercise_params
    params.require(:exercise).permit(:part, :exercise)
  end
end
