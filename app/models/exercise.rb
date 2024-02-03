class Exercise < ApplicationRecord
  belongs_to :user
  has_many :training_records
  validates :part, presence: true
  validates :exercise, presence: true
end