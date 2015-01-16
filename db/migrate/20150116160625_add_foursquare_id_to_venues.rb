class AddFoursquareIdToVenues < ActiveRecord::Migration
  def change
    add_reference :venues, :foursquare, index: true, null: false
  end
end
