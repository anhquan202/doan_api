class AddMonthAndYearToMeterReadings < ActiveRecord::Migration[8.0]
  def change
    add_column :meter_readings, :month, :integer
    add_column :meter_readings, :year, :integer
  end
end
