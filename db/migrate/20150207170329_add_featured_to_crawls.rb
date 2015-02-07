class AddFeaturedToCrawls < ActiveRecord::Migration
  def change
    add_column :crawls, :featured, :boolean, null: false, default: false
  end
end
