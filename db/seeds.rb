# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Room.find_each do |room|
  case room.room_type
  when "single"
    items = {
      "Giường ngủ" => 1,
      "Điều hoà" => 1,
      "Bình nóng lạnh" => 1
    }
  when "double"
    items = {
      "Giường ngủ" => 1,
      "Tủ quần áo" => 1,
      "Điều hoà" => 1,
      "Bình nóng lạnh" => 1
    }
  when "three"
    items = {
      "Giường ngủ" => 1,
      "Tủ quần áo" => 1,
      "Bàn ghế" => 1,
      "Điều hoà" => 1,
      "Bình nóng lạnh" => 1,
      "Tủ lạnh" => 1
    }
  end

  items.each do |name, quantity|
    supply = Supply.find_by(name: name)
    next unless supply

    RoomSupply.create!(
      room_id: room.id,
      supply_id: supply.id,
      quantity: quantity
    )
  end
  puts "🔄 Đang cập nhật Contract Utilities..."

  Contract.find_each do |contract|
    room = contract.room

    unless room
      puts "⚠️  Hợp đồng ##{contract.id} không có phòng tương ứng, bỏ qua."
      next
    end

    # Lấy tất cả utilities của room
    room_utilities = room.utilities

    if room_utilities.empty?
      puts "⚠️  Phòng #{room.room_name} (ID: #{room.id}) không có utilities, bỏ qua."
      next
    end

    # Lặp qua từng utility của room và tạo contract_utility nếu chưa tồn tại
    room_utilities.each do |utility|
      contract_utility = ContractUtility.find_or_create_by!(
        contract_id: contract.id,
        utility_id: utility.id
      )

      # Đặt status mặc định là active nếu bản ghi mới được tạo
      if contract_utility.status.nil?
        contract_utility.update!(status: :active)
      end

      puts "✅ Tạo/Cập nhật Contract Utility: Contract ##{contract.id} - Utility: #{utility.utility_type_label}"
    end
  end

  puts "✨ Hoàn thành cập nhật Contract Utilities!"
end
