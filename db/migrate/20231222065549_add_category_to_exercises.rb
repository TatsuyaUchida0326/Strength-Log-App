class AddCategoryToExercises < ActiveRecord::Migration[7.1]
  def change
    add_column :exercises, :category, :string
  end
end
