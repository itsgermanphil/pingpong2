class AddAdminFlagToUsers < ActiveRecord::Migration
  def change
    add_column :players, :admin, :boolean, default: false, null: false
  end
end
