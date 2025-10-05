class CreateRoomSupplies < ActiveRecord::Migration[8.0]
  def change
    create_table :room_supplies do |t|
      t.references :room, foreign_key: true
      t.references :supply, foreign_key: true
      t.integer :quantity
      t.integer :status
      t.timestamps
    end
  end
end
