class AddLastRoundIdToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :last_round_id, :integer
  end
end
