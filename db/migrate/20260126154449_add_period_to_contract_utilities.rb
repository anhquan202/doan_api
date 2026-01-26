class AddPeriodToContractUtilities < ActiveRecord::Migration[8.0]
  def change
    add_column :contract_utilities, :start_date, :date
    add_column :contract_utilities, :end_date, :date
    add_column :contract_utilities, :price, :decimal
  end
end
