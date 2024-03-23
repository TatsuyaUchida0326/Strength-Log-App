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
    
      # 重複チェック
      duplicate = Exercise.where(user_id: original_exercise.user_id, part: original_exercise.part, exercise: original_exercise.exercise, date: params[:date]).exists?
    
      if duplicate
        redirect_to exercises_path(date: params[:date]), alert: '既に該当のエクササイズは存在します。'
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
  
      # 重複チェック
      duplicate = current_user.exercises.where(part: @exercise.part, exercise: @exercise.exercise).exists?
  
      if duplicate
        flash[:alert] = '既に該当のエクササイズは存在します。'
        redirect_to exercises_path
      elsif @exercise.save
        flash[:notice] = 'トレーニングが追加されました。'
        redirect_to exercises_path
      else
        render :new
      end
    end

    def update
      @exercise = Exercise.find(params[:id])
      # training_records_attributes が存在する場合のみ、この処理を行う
      if params[:exercise]&.fetch(:training_records_attributes, nil)&.present?
        existing_record_ids = @exercise.training_records.pluck(:id) # 既存のtraining_recordsのidの配列を取得
        submitted_record_ids = params[:exercise][:training_records_attributes].values.map { |attr| attr[:id].to_i }.compact # パラメータで受け取ったtraining_records_attributesからidを抽出
        # 既存のもので、パラメータに含まれないものは削除する
        (existing_record_ids - submitted_record_ids).each do |id_to_remove|
          @exercise.training_records.find(id_to_remove).destroy
        end
      end
    
      if @exercise.update(exercise_params)
        flash[:success] = '内容が更新されました。'
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
    
    def show
      @exercise = current_user.exercises.find_by(id: params[:id])
      if @exercise.nil?
        redirect_to exercises_path, alert: '指定されたエクササイズが見つかりません。'
        return
      end
    end

    def destroy 
      @exercise = current_user.exercises.find_by(id: params[:id]) 
      if @exercise 
        if params[:delete_all].present? 
          exercises_to_destroy = current_user.exercises.where(exercise: @exercise.exercise) 
          if exercises_to_destroy.any? 
            exercises_to_destroy.each(&:destroy) 
            # 特定の日付にリダイレクトせず、一般的なエクササイズの一覧ページにリダイレクト 
            redirect_to exercises_path, alert: '関連する全てのエクササイズが削除されました。' 
          else 
            redirect_to exercises_path, alert: '記録がありません。' 
          end 
        else 
          if @exercise.training_records.any? 
            @exercise.training_records.destroy_all 
            # 特定の日付のトレーニング記録を削除した場合、その日付のページにリダイレクト 
            redirect_to exercises_path(date: @exercise.date&.strftime("%Y-%m-%d")), alert: 'トレーニング記録が削除されました。' 
          else 
            redirect_to exercises_path(date: @exercise.date&.strftime("%Y-%m-%d")), alert: '記録がありません。' 
          end 
        end 
      else 
        redirect_to exercises_path, alert: 'エクササイズが見つからないか、削除する権限がありません。' 
      end 
    end
    
    def bulk_delete_selected
      part = params[:part]
      selected_exercise_id = params[:exercise_id]
    
      # 選択された種目IDから種目名を取得
      selected_exercise = current_user.exercises.find_by(id: selected_exercise_id)
    
      # エラーハンドリング：選択された種目が存在しない場合
      unless selected_exercise
        redirect_to exercises_path, alert: "選択された種目が存在しません。"
        return
      end
    
      # 同じ部位・種目名の全てのレコードを削除
      exercises_to_destroy = current_user.exercises.where(part: part, exercise: selected_exercise.exercise)
    
      if exercises_to_destroy.destroy_all
        redirect_to exercises_path, alert: "選択された種目に関連する全ての記録が削除されました。"
      else
        redirect_to exercises_path, alert: "削除処理に失敗しました。"
      end
    end
    
    def index
      if params[:date]
        @selected_date = params[:date].to_date
        @exercises = current_user.exercises.where(date: @selected_date)
      else
        @exercises = current_user.exercises
      end
    
      # 部位ごとにユニークな種目リストを生成（SQLite対応）
      exercises_by_part = @exercises.group_by(&:part)
      @unique_exercises_by_part = exercises_by_part.transform_values do |exercises|
        exercises.uniq { |e| e.exercise }
      end
    end

    def strength_log
      @hide_header = true
      @one_rm_data = Exercise.one_rm_data(current_user)
      @unique_exercise_names = current_user.exercises.pluck(:exercise).uniq
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
      return if params[:delete_all].present? # 一括削除の場合はスキップ
      
      @exercise = current_user.exercises.find_by(id: params[:id])
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

