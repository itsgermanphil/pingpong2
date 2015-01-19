class AddNameToTier < ActiveRecord::Migration
  def change
    add_column :tiers, :name, :string
  end
end
