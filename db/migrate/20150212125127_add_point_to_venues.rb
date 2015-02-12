class AddPointToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :point, :point, null: false
  end
end
