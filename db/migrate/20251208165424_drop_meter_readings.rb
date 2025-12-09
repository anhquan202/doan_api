class DropMeterReadings < ActiveRecord::Migration[8.0]
  def change
    drop_table :meter_readings
  end
end
