class AddRowOrderToStops < ActiveRecord::Migration
  def change
    add_column :stops, :row_order, :integer
  end
end
