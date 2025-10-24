class Utility < ApplicationRecord
  has_many :room_utilities, dependent: :destroy
  has_many :rooms, through: :room_utilities

  enum :utility_type, electricity: 0, water: 1, internet: 2, parking: 3, garbage: 4, cleaning: 5

  def utility_type_label
    I18n.t("enums.utility.utility_type.#{utility_type}")
  end
end
