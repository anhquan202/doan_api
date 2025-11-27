class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :identity_code, :full_name, :gender, :date_of_birth, :status

  attribute :gender_text do
    I18n.t("enums.customer.gender.#{object.gender}", locale: :vi)
  end

  attribute :status_text do
    I18n.t("enums.customer.status.#{object.status}", locale: :vi)
  end
end
