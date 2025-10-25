class RoomSupplySerializer < ActiveModel::Serializer
  attributes :supply_id, :name, :unit, :quantity
end
