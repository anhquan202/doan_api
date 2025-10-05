class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :idenity_code
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :address
      t.integer :gender
      t.date :date_of_birth
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
