class MeterReadingSerializer < ActiveModel::Serializer
  attributes :contract_id, :contract_code, :fee_services

  has_many :electric_readings, serializer: ElectricReadingSerializer
  has_many :water_readings, serializer: WaterReadingSerializer

  def contract_id
    object.id
  end

  def contract_code
    object.contract_code
  end

  def electric_readings
    month = instance_options[:month]
    year = instance_options[:year]

    if month && year
      object.electric_readings.select { |er| er.month == month && er.year == year }
    else
      object.electric_readings
    end
  end

  def water_readings
    month = instance_options[:month]
    year = instance_options[:year]

    if month && year
      object.water_readings.select { |wr| wr.month == month && wr.year == year }
    else
      object.water_readings
    end
  end

  def fee_services
    object.fee_services
  end
end
