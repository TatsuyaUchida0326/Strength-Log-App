class CreateExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises do |t|
      t.string :part
      t.string :exercise

      t.timestamps
    end
  end
end
