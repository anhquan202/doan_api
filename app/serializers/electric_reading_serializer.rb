class ElectricReadingSerializer < ActiveModel::Serializer
  attributes :id, :start_num, :end_num, :fee_at_reading, :total_fee, :month, :year, :created_at, :updated_at

  belongs_to :contract, serializer: ContractSerializer
end
