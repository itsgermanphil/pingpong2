class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.integer :score
      t.belongs_to :player, index: true
      t.belongs_to :game, index: true

      t.timestamps null: false
    end
    add_foreign_key :participants, :players
    add_foreign_key :participants, :games
  end
end
