class AddImageUrlToCrawls < ActiveRecord::Migration
  def change
    add_column :crawls, :image_url, :text
  end
end
