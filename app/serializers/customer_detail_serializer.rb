class CustomerDetailSerializer < ActiveModel::Serializer
  attributes :id, :identity_code, :full_name, :email, :phone, :address, :gender, :date_of_birth, :room_name

  attribute :gender_text do
    I18n.t("enums.customer.gender.#{object.gender}", locale: :vi)
  end

  attribute :status_text do
    I18n.t("enums.customer.status.#{object.status}", locale: :vi)
  end

  def room_name
    object.contract&.room_name
  end
end
