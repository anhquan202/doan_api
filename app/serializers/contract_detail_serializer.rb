class ContractDetailSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :term_months, :deposit, :status, :room_id,
             :supplies, :utilities, :customers

  # Room supplies (if room and supplies association exist)
  def supplies
    room = object.respond_to?(:room) ? object.room : nil
    return [] unless room&.respond_to?(:supplies)

    room.supplies.map do |s|
      {
        id: s.id,
        name: s.respond_to?(:name) ? s.name : nil,
        description: s.respond_to?(:description) ? s.description : nil,
        # normalize quantity/amount to a single key if model uses different names
        quantity: (s.respond_to?(:quantity) && s.quantity) || (s.respond_to?(:amount) && s.amount) || 1
      }
    end
  end

  # Room utilities; include 'status' if contract has a join table that stores per-contract statuses
  def utilities
    room = object.respond_to?(:room) ? object.room : nil
    return [] unless room&.respond_to?(:utilities)

    room.utilities.map do |u|
      # Try to extract the per-contract utility status; support multiple possible associations
      status = nil
      if object.respond_to?(:contract_utilities)
        status = object.contract_utilities.find_by(utility_id: u.id)&.status
      elsif object.respond_to?(:contract_utilities_relations) # fallback name (if any)
        status = object.contract_utilities_relations.find { |cu| cu.utility_id == u.id }&.status
      elsif object.respond_to?(:utilities) # when contract has utilities association with status
        cu = object.utilities.find { |cu| cu.id == u.id } rescue nil
        status = cu&.status
      end

      {
        id: u.id,
        name: u.respond_to?(:name) ? u.name : nil,
        unit: u.respond_to?(:unit) ? u.unit : nil,
        status: status
      }
    end
  end

  # Customers on the contract, include representation flag
  def customers
    return [] unless object.respond_to?(:customers)

    object.customers.map do |c|
      {
        id: c.id,
        identity_code: c.respond_to?(:identity_code) ? c.identity_code : nil,
        first_name: c.respond_to?(:first_name) ? c.first_name : nil,
        last_name: c.respond_to?(:last_name) ? c.last_name : nil,
        full_name: [
          (c.respond_to?(:first_name) ? c.first_name : nil),
          (c.respond_to?(:last_name) ? c.last_name : nil)
        ].compact.join(" "),
        email: c.respond_to?(:email) ? c.email : nil,
        phone: c.respond_to?(:phone) ? c.phone : nil,
        address: c.respond_to?(:address) ? c.address : nil,
        gender: c.respond_to?(:gender) ? c.gender : nil,
        date_of_birth: c.respond_to?(:date_of_birth) ? c.date_of_birth : nil,
        is_represent: c.respond_to?(:is_represent) ? !!c.is_represent : false
      }
    end
  end
end
