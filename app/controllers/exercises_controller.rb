  class ExercisesController < ApplicationController
    before_action :set_exercise, only: [:show, :edit, :update, :destroy]

    def new
      @exercise = Exercise.new
      @exercise.date = params[:date] if params[:date].present?
    end

    def add_existing
      original_exercise = Exercise.find_by(id: params[:exercise_id])

      # トレーニング種目が見つからない場合の処理
      unless original_exercise
        redirect_to exercises_path, alert: '指定されたトレーニング種目が見つかりません。'
        return
      end

      new_exercise = original_exercise.dup
      new_exercise.date = params[:date]

      if new_exercise.save
        redirect_to exercises_path(date: new_exercise.date.strftime("%Y-%m-%d")), notice: 'トレーニングが追加されました。'
      else
        redirect_to exercises_path, alert: 'トレーニングの追加に失敗しました。'
      end
    end

    def create
      @exercise = current_user.exercises.build(exercise_params)
      if @exercise.save
        flash[:notice] = 'トレーニングが追加されました。'
        redirect_to exercises_path # 日付パラメータを指定しない
      else
        render :new
      end
    end

    def update
      @exercise = Exercise.find(params[:id])
      # training_records_attributes が存在する場合のみ、この処理を行う
      if params[:exercise][:training_records_attributes].present?
        existing_record_ids = @exercise.training_records.pluck(:id) # 既存のtraining_recordsのidの配列を取得
        submitted_record_ids = params[:exercise][:training_records_attributes].values.map { |attr| attr[:id].to_i }.compact # パラメータで受け取ったtraining_records_attributesからidを抽出
        # 既存のもので、パラメータに含まれないものは削除する
        (existing_record_ids - submitted_record_ids).each do |id_to_remove|
          @exercise.training_records.find(id_to_remove).destroy
        end
      end
    
      if @exercise.update(exercise_params)
        flash[:success] = '記録が更新されました。'
        # 日付に基づいてリダイレクトする場合、@exercise.dateが存在することを確認
        if @exercise.date
          redirect_to exercises_path(date: @exercise.date.strftime("%Y-%m-%d"))
        else
          # 日付が存在しない場合は、トップレベルのエクササイズ一覧にリダイレクト
          redirect_to exercises_path
        end
      else
        render :edit
      end
    end

    def destroy
      @exercise = current_user.exercises.find_by(id: params[:id])

      if @exercise
        date_of_exercise = @exercise.date.strftime("%Y-%m-%d") # トレーニングの日付を取得
        @exercise.destroy
        redirect_to exercises_path(date: date_of_exercise), notice: 'エクササイズが削除されました。'
      else
        redirect_to exercises_path, alert: 'エクササイズが見つからないか、削除する権限がありません。'
      end
    end

    def index
      if params[:date]
        @selected_date = params[:date].to_date
        @exercises = Exercise.where(date: @selected_date)
      else
        @exercises = Exercise.all
      end
    end

    def show
      @exercise = Exercise.find(params[:id])
    end

    def strength_log
      @exercises = Exercise.order(:part)
    end

    def edit
      @exercise = Exercise.find(params[:id])
    end

    def calculate_one_rm
      # 1RM 計算ロジックを更新
      @one_rm = (params[:weight].to_f * params[:reps].to_i / 40.0) + params[:weight].to_f
      respond_to do |format| 
        format.turbo_stream
      end
    end

    private

    def set_exercise
      @exercise = Exercise.find_by(id: params[:id])
      unless @exercise
        redirect_to exercises_path, alert: "指定されたトレーニングが見つかりません。"
      end
    end

    # Strong Parametersを使用して安全にパラメータを取り扱う
    def exercise_params
      params.require(:exercise).permit(
        :part,
        :exercise,
        :date,
        training_records_attributes: [
          :id,
          :weight,
          :reps,
          :one_rm,
          :comment,
          :_destroy
        ]
      )
    end

    def build_exercise(params)
      if params[:exercise_id].present?
        original_exercise = Exercise.find(params[:exercise_id])
        exercise = original_exercise.dup
        exercise.date = params[:date]
        exercise.user = current_user
      else
        exercise = current_user.exercises.build(params)
      end
      exercise
    end
  end
  