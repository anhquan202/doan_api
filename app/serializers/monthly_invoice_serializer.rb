class MonthlyInvoiceSerializer < ActiveModel::Serializer
  attributes :id, :contract_id, :contract_code, :room_name,
             :month, :year, :period_text,
             :room_fee, :electric_fee, :water_fee, :service_fee,
             :service_details, :adjustment, :adjustment_note,
             :total_amount, :status, :status_text,
             :paid_at, :payment_method, :note,
             :created_at, :updated_at

  def contract_code
    object.contract&.contract_code
  end

  def room_name
    object.contract&.room_name
  end

  def paid_at
    object.paid_at&.strftime("%Y-%m-%d %H:%M:%S")
  end
end

