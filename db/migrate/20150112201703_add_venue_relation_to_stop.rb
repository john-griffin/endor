class AddVenueRelationToStop < ActiveRecord::Migration
  def change
    add_reference :stops, :venue, index: true
    add_foreign_key :stops, :venues
  end
end
