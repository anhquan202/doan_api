class CreateContractUtilities < ActiveRecord::Migration[8.0]
  def change
    create_table :contract_utilities do |t|
      t.references :contract
      t.references :utility
      t.integer :quantity, default: 1
      t.integer :status
      t.timestamps
    end
  end
end
