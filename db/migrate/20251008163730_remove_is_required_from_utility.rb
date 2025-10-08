class RemoveIsRequiredFromUtility < ActiveRecord::Migration[8.0]
  def change
    remove_column :utilities, :is_required, :boolean
  end
end
