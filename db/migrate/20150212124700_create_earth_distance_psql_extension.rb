class CreateEarthDistancePsqlExtension < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION \"cube\";"
    execute "CREATE EXTENSION \"earthdistance\";"
  end

  def down
    execute "DROP EXTENSION \"earthdistance\";"
    execute "DROP EXTENSION \"cube\";"
  end
end
