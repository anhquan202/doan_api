class RemoveSupplyTypeFromSupply < ActiveRecord::Migration[8.0]
  def change
    remove_column :supplies, :supply_type, :integer
  end
end
