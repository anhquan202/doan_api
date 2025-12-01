class ContractDetailSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :term_months, :deposit, :status, :room_info

  has_many :customers, serializer: CustomerSerializer

  def room_info
    {
      id: object.room.id,
      name: object.room_name,
      supplies: object.room.supplies,
      utilities: object.utilities
    }
  end
end
