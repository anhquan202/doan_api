class Admin::ImportMeterReadingXlsxService
  def initialize(file)
    @file = file
  end

  def call
    tempfile = @file[:tempfile]
    xlsx = Roo::Spreadsheet.open(tempfile.path, extension: :xlsx)
    sheet = xlsx.sheet(0)
    rows = sheet.each_row_streaming.map { |r| r.map(&:value) }

    period_text = rows[0][0]
    month, year = extract_month_year(period_text)

    data_rows = rows.drop(4)

    created_records = [] # để trả về thông tin đã tạo

    Room.transaction do
      data_rows.each do |row|
        next if row.compact.empty?
        next if row[0].nil?

        # bắt buộc phải có đủ số
        next if [ row[1], row[2], row[3], row[5], row[6], row[7] ].any?(&:nil?)

        room = Room.find_by_room_name(row[0])
        contract = room&.contracts&.active&.first
        next if contract.nil?

        # Tạo meter điện
        meter_electric = MeterReading.create!(
          contract_id:     contract.id,
          reading_type:    0,
          start_num:       row[1],
          end_num:         row[2],
          fee_at_reading:  row[3],
          total_fee:       safe_total(row[1], row[2], row[3]),
          month:           month,
          year:            year
        )

        # Tạo meter nước
        meter_water = MeterReading.create!(
          contract_id:     contract.id,
          reading_type:    1,
          start_num:       row[5],
          end_num:         row[6],
          fee_at_reading:  row[7],
          total_fee:       safe_total(row[5], row[6], row[7]),
          month:           month,
          year:            year
        )

        created_records << {
          room: room.room_name,
          contract_id: contract.id,
          electric_id: meter_electric.id,
          water_id: meter_water.id
        }
      end
    end

    {
      month: month,
      year: year,
      detail: created_records
    }
  end

  private

  def safe_total(start_num, end_num, fee)
    return nil if start_num.nil? || end_num.nil? || fee.nil?
    (end_num - start_num) * fee
  end

  def extract_month_year(text)
    m = text.match(/Tháng\s+(\d+)\/(\d+)/)
    [ m[1].to_i, m[2].to_i ]
  end
end
