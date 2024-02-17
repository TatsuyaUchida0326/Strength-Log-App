class TrainingRecord < ApplicationRecord
  belongs_to :exercise
  
  validates :weight, presence: true
  validates :reps, presence: true
  # 他の必須フィールドに対しても同様のバリデーションを追加
end
