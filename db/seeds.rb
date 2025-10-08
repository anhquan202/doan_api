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
end
