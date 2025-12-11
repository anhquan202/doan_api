class MeterReadingSerializer < ActiveModel::Serializer
  attributes :contract_id, :contract_code, :fee_services, :electric_reading, :water_reading

  def contract_id
    object.id
  end

  def contract_code
    object.contract_code
  end

  def electric_reading
    month = instance_options[:month]
    year = instance_options[:year]

    if month && year
      reading = object.electric_readings.find { |er| er.month == month && er.year == year }
      reading ? ActiveModelSerializers::SerializableResource.new(reading, serializer: ElectricReadingSerializer) : nil
    else
      object.electric_readings.first ? ActiveModelSerializers::SerializableResource.new(object.electric_readings.first, serializer: ElectricReadingSerializer) : nil
    end
  end

  def water_reading
    month = instance_options[:month]
    year = instance_options[:year]

    if month && year
      reading = object.water_readings.find { |wr| wr.month == month && wr.year == year }
      reading ? ActiveModelSerializers::SerializableResource.new(reading, serializer: WaterReadingSerializer) : nil
    else
      object.water_readings.first ? ActiveModelSerializers::SerializableResource.new(object.water_readings.first, serializer: WaterReadingSerializer) : nil
    end
  end

  def fee_services
    object.fee_services
  end
end
