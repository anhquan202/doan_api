class DropVehiclesTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :vehicles
  end
end
