class AddStatusToContractSupplies < ActiveRecord::Migration[8.0]
  def change
    add_column :contract_supplies, :status, :integer, default: 1
  end
end
