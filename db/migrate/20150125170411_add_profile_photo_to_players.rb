class AddProfilePhotoToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :image, :string
    add_column :players, :nickname, :string
  end
end
