class ContractDetailSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :contract_code, :room_info

  has_many :customers, serializer: CustomerSerializer

  def room_info
    {
      id: object.room.id,
      name: object.room_name,
      supplies: object.room.supplies,
      utilities: serialized_utilities
    }
  end

  private
  def serialized_utilities
    object.utilities.map do |u|
      UtilitySerializer.new(u, scope: scope, root: false).as_json
    end
  end
end
