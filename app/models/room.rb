class Room < ApplicationRecord
  before_validation :set_max_customers, on: [ :create, :update ]
  before_validation :set_room_name, on: :create

  has_many :room_supplies, dependent: :destroy
  has_many :room_utilities, dependent: :destroy

  has_many :supplies, through: :room_supplies, dependent: :destroy
  has_many :utilities, through: :room_utilities, dependent: :destroy

  enum :room_type, single: 0, double: 1, three: 3
  enum :status, available: 0, occupied: 1, cleaning: 2, repairing: 3, default: :available

  accepts_nested_attributes_for :room_supplies, allow_destroy: true
  accepts_nested_attributes_for :room_utilities, allow_destroy: true

  private

  def set_room_name
    last_room = Room.order(:room_name).last

    if last_room&.room_name&.match(/P(\d{3})/)
      last_number = $1.to_i
      next_number = last_number + 1
    else
      next_number = 1
    end

    self.room_name = "P%03d" % next_number
  end

  def set_max_customers
    self.max_customers =
      case room_type
      when "single" then 1
      when "double" then 2
      when "three"  then 3
      else 0
      end
  end
end
