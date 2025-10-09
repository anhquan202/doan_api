class AddCascadeDeleteToRoomUtilities < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :room_utilities, :rooms
    add_foreign_key :room_utilities, :rooms, on_delete: :cascade
  end
end
