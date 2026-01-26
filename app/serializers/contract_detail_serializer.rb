class ContractDetailSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :contract_code, :room_info

  has_many :customers, serializer: CustomerSerializer

  def room_info
    {
      id: object.room.id,
      name: object.room_name,
      supplies: object.supplies,
      utilities: ActiveModelSerializers::SerializableResource.new(
        object.utilities,
        each_serializer: UtilitySerializer
      )
    }
  end
end
