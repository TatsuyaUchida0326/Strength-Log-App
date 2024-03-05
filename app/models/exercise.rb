class Exercise < ApplicationRecord 
  belongs_to :user 
  has_many :training_records, dependent: :destroy 
  accepts_nested_attributes_for :training_records, reject_if: proc { |attributes|  
    attributes['weight'].blank? && attributes['reps'].blank?  
  }, allow_destroy: true 
 
  validates :part, presence: true 
  validates :exercise, presence: true 
 
  # 1RMデータの集計用クラスメソッド（exercise_idを含むように修正） 
  def self.one_rm_data(user) 
    TrainingRecord.joins(:exercise) 
                  .where(exercises: { user_id: user.id }) 
                  .select('exercises.date, exercises.exercise, exercises.id as exercise_id, MAX(training_records.one_rm) as max_one_rm') 
                  .group('exercises.date', 'exercises.exercise', 'exercises.id') 
                  .map do |record| 
                    { 
                      date: record.date, 
                      exercise: record.exercise, 
                      exercise_id: record.exercise_id, # 追加 
                      one_rm: record.max_one_rm 
                    } 
                  end 
  end 
end 
