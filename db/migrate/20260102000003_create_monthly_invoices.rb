class CreateMonthlyInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :monthly_invoices do |t|
      t.references :contract, null: false, foreign_key: true
      t.integer :month, null: false
      t.integer :year, null: false

      # Snapshot giá tại thời điểm tạo hóa đơn
      t.decimal :room_fee, precision: 12, scale: 0, default: 0
      t.decimal :electric_fee, precision: 12, scale: 0, default: 0
      t.decimal :water_fee, precision: 12, scale: 0, default: 0
      t.decimal :service_fee, precision: 12, scale: 0, default: 0

      # Chi tiết dịch vụ (JSON để lưu breakdown)
      t.json :service_details, default: []

      # Điều chỉnh
      t.decimal :adjustment, precision: 12, scale: 0, default: 0
      t.string :adjustment_note

      # Tổng cộng
      t.decimal :total_amount, precision: 12, scale: 0, default: 0

      # Thanh toán
      t.integer :status, default: 0, null: false
      t.datetime :paid_at
      t.string :payment_method
      t.text :note

      t.timestamps
    end

    add_index :monthly_invoices, [:contract_id, :month, :year], unique: true, name: "idx_invoices_contract_period"
    add_index :monthly_invoices, :status
    add_index :monthly_invoices, [:year, :month]
  end
end

