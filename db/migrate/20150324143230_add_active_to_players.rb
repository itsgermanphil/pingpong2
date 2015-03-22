class AddActiveToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :active, :boolean, null: false, default: true
  end
end
