class CreateUtilities < ActiveRecord::Migration[8.0]
  def change
    create_table :utilities do |t|
      t.integer :utility_type
      t.boolean :is_required
      t.decimal :fee, precision: 10
      t.text :description
      t.timestamps
    end
  end
end
