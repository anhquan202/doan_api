class CreateContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :contracts do |t|
      t.references :room, foreign_key: true
      t.string :contract_code
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :deposit, precision: 10
      t.integer :status
      t.timestamps
    end
  end
end
