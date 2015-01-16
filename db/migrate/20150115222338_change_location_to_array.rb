class ChangeLocationToArray < ActiveRecord::Migration
  def change
    change_column :venues, :location, "text[] USING (string_to_array(location, ','))"
  end
end
