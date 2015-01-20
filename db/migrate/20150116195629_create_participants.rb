class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.belongs_to :player, index: true
      t.belongs_to :round, index: true
      t.belongs_to :tier, index: true

      t.timestamps null: false
    end
  end
end
