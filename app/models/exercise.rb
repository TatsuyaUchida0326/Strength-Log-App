class Exercise < ApplicationRecord
  validates :part, presence: true
  validates :exercise, presence: true
end