class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.belongs_to :tier, index: true

      t.timestamps null: false
    end
    add_foreign_key :games, :tiers
  end
end
