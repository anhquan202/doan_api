class CreateRoomUtility < ActiveRecord::Migration[8.0]
  def change
    create_table :room_utilities do |t|
      t.references :room, foreign_key: true
      t.references :utility, foreign_key: true
      t.integer :is_required
      t.timestamps
    end
  end
end
