class ContractSupply < ActiveRecord::Migration[8.0]
  def change
    create_table :contract_supplies do |t|
      t.references :contract, null: false, foreign_key: true
      t.references :supply, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :price, precision: 12, scale: 2
      t.integer :quantity, default: 1
      t.timestamps
    end

    add_index :contract_supplies,
              [ :contract_id, :supply_id, :start_date ],
              unique: true,
              name: "idx_contract_supply_period"
  end
end
