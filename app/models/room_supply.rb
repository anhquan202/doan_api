class RoomSupply < ApplicationRecord
  belongs_to :room
  belongs_to :supply

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  delegate :id, :name, :unit, to: :supply
end
