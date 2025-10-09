class AddCascadeDeleteToRoomSupplies < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :room_supplies, :rooms
    add_foreign_key :room_supplies, :rooms, on_delete: :cascade
  end
end
