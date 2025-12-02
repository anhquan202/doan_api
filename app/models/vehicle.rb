class Vehicle < ApplicationRecord
  scope :active, -> { where(is_active: true) }

  def toggle_active!
    update!(is_active: !is_active)
  end

  def name_i18n
    I18n.t("activerecord.attributes.vehicle.name.#{name}")
  end
end
