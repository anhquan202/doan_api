class ContractSerializer < ActiveModel::Serializer
  attributes :id, :contract_code, :start_date_formatted, :end_date_formatted, :term_months, :deposit, :room_name, :representative_name, :customers_count, :status, :status_text
end
