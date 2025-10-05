class CreateContractCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :contract_customers do |t|
      t.references :contract, foreign_key: true, null: false
      t.references :customer, foreign_key: true, null: false
      t.boolean :is_represent
      t.datetime :move_in_date
      t.datetime :move_out_date
      t.timestamps
    end
  end
end
