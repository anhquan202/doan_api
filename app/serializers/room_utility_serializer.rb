class RoomUtilitySerializer < ActiveModel::Serializer
  attributes :utility_id, :is_required, :utility_type, :fee
end
