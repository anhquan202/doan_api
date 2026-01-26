class AddSuppliesUtilitiesToContractDrafts < ActiveRecord::Migration[8.0]
  def change
    add_column :contract_drafts, :supplies_data, :json
    add_column :contract_drafts, :utilities_data, :json
  end
end
