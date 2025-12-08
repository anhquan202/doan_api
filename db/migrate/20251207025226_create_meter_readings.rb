class CreateMeterReadings < ActiveRecord::Migration[8.0]
  def change
    create_table :meter_readings do |t|
      t.references :contract, null: false, foreign_key: true
      t.integer :reading_type, null: false, default: 0
      t.integer :start_num, null: false
      t.integer :end_num, null: false
      t.decimal :fee_at_reading, precision: 10, scale: 2, null: false
      t.decimal :total_fee, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :meter_readings, [ :contract_id, :reading_type ]
  end
end
