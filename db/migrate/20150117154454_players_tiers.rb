class PlayersTiers < ActiveRecord::Migration
  def change
    create_table :players_tiers, id: false do |t|
      t.integer :player_id
      t.integer :tier_id
    end

    add_index :players_tiers, :player_id
    add_index :players_tiers, :tier_id
  end
end
