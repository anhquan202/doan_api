class RoomUtility < ApplicationRecord
  belongs_to :room
  belongs_to :utility

  delegate :id, :utility_type, :fee, to: :utility
end
