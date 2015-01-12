class CreateStops < ActiveRecord::Migration
  def change
    create_table :stops do |t|
      t.string :name
      t.belongs_to :crawl, index: true

      t.timestamps null: false
    end
    add_foreign_key :stops, :crawls
  end
end
