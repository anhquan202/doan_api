class RoomDetailSerializer < ActiveModel::Serializer
  attributes :id, :room_type, :room_name, :status, :price, :max_customers, :description

  has_many :room_supplies, serializer: RoomSupplySerializer
  has_many :room_utilities, serializer: RoomUtilitySerializer
end
