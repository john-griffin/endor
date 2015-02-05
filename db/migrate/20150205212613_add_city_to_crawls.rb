class AddCityToCrawls < ActiveRecord::Migration
  def change
    add_column :crawls, :city, :string, null: false
  end
end
