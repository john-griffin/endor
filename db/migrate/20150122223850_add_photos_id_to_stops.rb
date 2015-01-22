class AddPhotosIdToStops < ActiveRecord::Migration
  def change
    remove_column :venues, :photo_url, :string
    add_column :stops, :photo_prefix, :string, null: false
    add_column :stops, :photo_suffix, :string, null: false
    add_column :stops, :photo_id, :string, null: false
    add_index :stops, :photo_id
  end
end
