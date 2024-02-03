class CreateTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :training_records do |t|
      t.integer :set
      t.decimal :weight
      t.integer :reps
      t.decimal :one_rm
      t.references :exercise, null: false, foreign_key: true

      t.timestamps
    end
  end
end
