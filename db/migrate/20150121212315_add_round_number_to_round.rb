class AddRoundNumberToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :round_number, :integer

    Round.order(:id).all.each.with_index do |r, id|
      r.round_number = id + 1
      r.save!
    end
  end
end
