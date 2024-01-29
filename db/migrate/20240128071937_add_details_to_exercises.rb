class AddDetailsToExercises < ActiveRecord::Migration[7.1]
  def change
    add_column :exercises, :sets, :integer
    add_column :exercises, :weight, :integer
    add_column :exercises, :reps, :integer
  end
end
