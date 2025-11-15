class UtilitySerializer < ActiveModel::Serializer
  attributes :id, :utility_type, :utility_type_label, :fee, :description, :is_required

  def is_required
    instance_options[:room_utility]&.is_required
  end
end
