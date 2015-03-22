class AddElo < ActiveRecord::Migration
  def up
    add_column :players, :elo_rating, :float, null: false, default: 1000

    add_column :games, :elo_rating1_in, :float
    add_column :games, :elo_rating1_out, :float

    add_column :games, :elo_rating2_in, :float
    add_column :games, :elo_rating2_out, :float

    add_column :games, :finished_at, :timestamp

    add_column :rounds, :public, :boolean, default: true, null: false

    Game.order(:updated_at).where('score1 is not null').find_each do |g|
      g.finished_at = g.updated_at
      g.apply_elo_ratings
      g.save!
    end

    # Free-play round/tier
    r = Round.new
    r.public = false
    r.start_date = Time.now
    r.round_number = 0
    r.save!

    t = Tier.new
    t.round = r
    t.save!
  end

  def down
    Round.where(public: false).each do |r|
      Game.where(round_id: r.id).destroy_all
      Tier.where(round_id: r.id).destroy_all
      r.destroy
    end

    remove_column :players, :elo_rating
    remove_column :games, :elo_rating1_in
    remove_column :games, :elo_rating1_out
    remove_column :games, :elo_rating2_in
    remove_column :games, :elo_rating2_out
    remove_column :games, :finished_at
    remove_column :rounds, :public


  end

end
