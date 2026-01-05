class MonthlyInvoiceDetailSerializer < ActiveModel::Serializer
  attributes :id, :contract_id, :contract_code, :room_name,
             :month, :year, :period_text,
             :room_fee, :electric_fee, :water_fee, :service_fee,
             :service_details, :adjustment, :adjustment_note,
             :total_amount, :status, :status_text,
             :paid_at, :payment_method, :note,
             :electric_reading, :water_reading,
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

  def electric_reading
    reading = object.electric_reading
    return nil unless reading

    {
      id: reading.id,
      start_num: reading.start_num,
      end_num: reading.end_num,
      usage: reading.end_num - reading.start_num,
      fee_at_reading: reading.fee_at_reading,
      total_fee: reading.total_fee
    }
  end

  def water_reading
    reading = object.water_reading
    return nil unless reading

    {
      id: reading.id,
      start_num: reading.start_num,
      end_num: reading.end_num,
      usage: reading.end_num - reading.start_num,
      fee_at_reading: reading.fee_at_reading,
      total_fee: reading.total_fee
    }
  end
end

