class AddDateToExercises < ActiveRecord::Migration[7.1]
  def change
    add_column :exercises, :date, :date
  end
end
