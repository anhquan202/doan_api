class RenameIdenityCodeToIdentityCodeInCustomers < ActiveRecord::Migration[8.0]
  def change
    rename_column :customers, :idenity_code, :identity_code
  end
end
