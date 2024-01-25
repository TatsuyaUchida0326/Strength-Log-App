class Exercise < ApplicationRecord
  belongs_to :user  # この行を追加
  validates :part, presence: true
  validates :exercise, presence: true
end