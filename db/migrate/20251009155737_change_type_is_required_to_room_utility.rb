class ChangeTypeIsRequiredToRoomUtility < ActiveRecord::Migration[8.0]
  def change
    change_column :room_utilities, :is_required, :boolean
  end
end
