class AddVehicleDataToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :vehicle_data, :json, default: nil
  end
end

