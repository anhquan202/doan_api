class CreateContractDrafts < ActiveRecord::Migration[8.0]
  def change
    create_table :contract_drafts do |t|
      t.references :room, null: false, foreign_key: true
      t.integer :current_step, default: 1, null: false
      t.json :customers_data, default: []
      t.date :start_date
      t.integer :term_months
      t.decimal :deposit, precision: 10
      t.integer :status, default: 0, null: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :contract_drafts, :status
    add_index :contract_drafts, :expires_at
  end
end

