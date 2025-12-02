class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.string :name
      t.text :description
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end
