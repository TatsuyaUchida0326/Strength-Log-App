class AddCommentToTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :training_records, :comment, :string
  end
end
