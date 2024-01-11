class AddNameToExercises < ActiveRecord::Migration[7.1]
  def change
    add_column :exercises, :name, :string
  end
end
