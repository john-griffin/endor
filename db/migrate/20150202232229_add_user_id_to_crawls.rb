class AddUserIdToCrawls < ActiveRecord::Migration
  def change
    add_reference :crawls, :user, index: true, null: false
    add_foreign_key :crawls, :users
  end
end
