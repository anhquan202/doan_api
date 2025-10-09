class RoomSerializer < ActiveModel::Serializer
  attributes :id, :room_type, :room_name, :status, :price, :max_customers, :description

  has_many :supplies, serializer: SupplySerializer
  has_many :utilities, serializer: UtilitySerializer
end
