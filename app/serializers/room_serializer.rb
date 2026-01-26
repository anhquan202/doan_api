class RoomSerializer < ActiveModel::Serializer
  attributes :id, :room_type, :room_name, :status, :price, :max_customers, :description, :room_type_label

  has_many :supplies, serializer: SupplySerializer do
    object.supplies.order(id: :asc)
  end

  # attribute :utilities

  # def utilities
  #   rus = object.association(:room_utilities).loaded? ? object.room_utilities : object.room_utilities.includes(:utility)
  #   rus.sort_by { |ru| ru.utility.id }.map do |ru|
  #     UtilitySerializer.new(ru.utility, room_utility: ru).as_json
  #   end
  # end

  attribute :utilities

  def utilities
    rus = object.room_utilities.includes(:utility).order("utilities.id")

    rus.map do |ru|
      UtilitySerializer.new(
        ru.utility,
        room_utility: ru
      ).as_json
    end
  end
end
