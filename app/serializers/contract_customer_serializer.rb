class ContractCustomerSerializer < ActiveModel::Serializer
  attributes :id, :identity_code, :first_name, :last_name, :full_name,
             :email, :phone, :address, :gender, :date_of_birth, :is_represent

  def full_name
    if object.respond_to?(:full_name)
      object.full_name
    else
      "#{object.first_name} #{object.last_name}".strip
    end
  end
end
