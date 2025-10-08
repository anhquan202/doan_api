class Supply < ApplicationRecord
  has_many :room_supplies, dependent: :destroy
  has_many :rooms, through: :room_supplies

  enum :unit, piece: 0, set: 1, unitless: 2
end
