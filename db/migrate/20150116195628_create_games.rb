class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :round, index: true

      t.references :participant1, index: true
      t.references :participant2, index: true

      t.integer :score1
      t.integer :score2

      t.timestamps null: false
    end
  end
end
