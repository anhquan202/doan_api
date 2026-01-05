class Customer < ApplicationRecord
  has_one :contract_customer, dependent: :destroy
  has_one :contract, through: :contract_customer

  delegate :room_name, to: :contract, allow_nil: true

  enum :status, active: 0, warning: 1, banned: 2
  enum :gender, male: 0, female: 1

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, :address, presence: true
  validates :identity_code, presence: true, uniqueness: true

  # Vehicle data stored as JSON: { vehicle_id, vehicle_name, plate_number }
  # Example: { "vehicle_id": 1, "vehicle_name": "motorcycle", "plate_number": "29A-12345" }

  def full_name
    "#{first_name} #{last_name}"
  end

  def plate_number
    vehicle_data&.dig("plate_number")
  end

  def vehicle_name
    return nil unless vehicle_data&.dig("vehicle_id")

    Vehicle.find_by(id: vehicle_data["vehicle_id"])&.name_i18n
  end

  def vehicle_info
    return nil if vehicle_data.blank?

    {
      vehicle_id: vehicle_data["vehicle_id"],
      vehicle_name: vehicle_name,
      plate_number: vehicle_data["plate_number"]
    }
  end
end
