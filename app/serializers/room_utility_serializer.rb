class RoomUtilitySerializer < ActiveModel::Serializer
  attributes :utility_id, :is_required, :utility_type, :fee, :utility_type_label

  def utility_type_label
    I18n.t("activerecord.attributes.utility.utility_types.#{object.utility.utility_type}")
  end
end
