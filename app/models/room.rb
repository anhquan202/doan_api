class Room < ApplicationRecord
  has_many :room_supplies, dependent: :destroy
  has_many :room_utilities, dependent: :destroy

  has_many :supplies, through: :room_supplies, dependent: :destroy
  has_many :utilities, through: :room_utilities, dependent: :destroy

  enum :room_type, single: 0, double: 1, three: 3
  enum :status, available: 0, occupied: 1, cleaning: 2, repairing: 3

  accepts_nested_attributes_for :room_supplies, allow_destroy: true
  accepts_nested_attributes_for :room_utilities, allow_destroy: true
end
