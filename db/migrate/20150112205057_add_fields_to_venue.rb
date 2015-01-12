class AddFieldsToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :description, :text
    add_column :venues, :photo_url, :string
    add_column :venues, :location, :string
  end
end
