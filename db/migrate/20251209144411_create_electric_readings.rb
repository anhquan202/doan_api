class CreateElectricReadings < ActiveRecord::Migration[8.0]
  def change
    create_table :electric_readings do |t|
      t.references :contract, null: false, foreign_key: true
      t.integer :start_num
      t.integer :end_num
      t.integer :fee_at_reading
      t.integer :total_fee
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end
end
