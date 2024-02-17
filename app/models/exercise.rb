class Exercise < ApplicationRecord
  belongs_to :user
  has_many :training_records, dependent: :destroy
  accepts_nested_attributes_for :training_records, reject_if: proc { |attributes|
    attributes['weight'].blank? && attributes['reps'].blank?
  }, allow_destroy: true

  validates :part, presence: true
  validates :exercise, presence: true
end
