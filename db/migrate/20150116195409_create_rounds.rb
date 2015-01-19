class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
