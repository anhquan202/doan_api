class RoomSerializer < ActiveModel::Serializer
  attributes :id, :room_type, :room_name, :status, :price, :max_customers, :description, :room_type_label

  has_many :supplies, serializer: SupplySerializer do
    object.supplies.order(id: :asc)
  end

  has_many :utilities do
    object.room_utilities.includes(:utility).sort_by { |ru| ru.utility.id }.map do |ru|
      UtilitySerializer.new(ru.utility, room_utility: ru).as_json
    end
  end
end
