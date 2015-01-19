class AddUidToUsers < ActiveRecord::Migration
  def change
    add_column :players, :uid, :string
  end
end
