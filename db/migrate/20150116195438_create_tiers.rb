class CreateTiers < ActiveRecord::Migration
  def change
    create_table :tiers do |t|
      t.belongs_to :round, index: true

      t.timestamps null: false
    end
    add_foreign_key :tiers, :rounds
  end
end
