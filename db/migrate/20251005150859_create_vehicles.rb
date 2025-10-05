class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.references :customer, foreign_key: true
      t.string :license_plate
      t.integer :vehicle_type
      t.timestamps
    end
  end
end
