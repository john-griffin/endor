class AddFoursquareIdToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :foursquare_id, :string, null: false
    add_index :venues, :foursquare_id
  end
end
