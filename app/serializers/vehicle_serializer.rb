class VehicleSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :is_active

  def name
    object.name_i18n
  end
end
