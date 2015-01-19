class AddLevelToTier < ActiveRecord::Migration
  def change
    add_column :tiers, :level, :integer
  end
end
