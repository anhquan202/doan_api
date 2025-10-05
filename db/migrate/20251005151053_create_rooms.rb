class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.integer :room_type
      t.string :room_name
      t.decimal :price, precision: 10
      t.integer :status
      t.integer :max_customers
      t.text :description, null: true
      t.timestamps
    end
  end
end
